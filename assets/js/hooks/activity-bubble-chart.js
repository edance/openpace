import * as d3 from "d3";
import RBush from "rbush";

/*
 * ActivityBubbleChart Hook
 * D3 chart based on https://observablehq.com/@ch-bu/bubble-chart-split-my-running-by-year
 * Rewritten using canvas to be more performant for the force animations
 * Uses rtree to find the hovering node that is being hovered over
 * Axis drawing https://observablehq.com/@spattana/drawing-axis-in-d3-canvas
 */
export default {
  mounted() {
    // set the dimensions and margins of the graph
    const margin = { top: 30, right: 30, left: 120, bottom: 30 };
    const container = d3.select(this.el);

    // Get the height and width from the container element
    const width = this.el.clientWidth;
    const height = this.el.clientHeight;

    // Inner section (not working yet)
    const innerWidth = width - margin.left - margin.right;
    const innerHeight = height - margin.top - margin.bottom;

    // Get the dpi to calculate the height/width for pixel devices
    const dpi = devicePixelRatio;

    const svg = container.append("svg").attr("viewBox", [0, 0, width, height]);

    // Need to have position relative for canvas position absolute to work
    container.style("position", "relative");

    const wrapper = svg
      .append("g")
      .attr("transform", `translate(${margin.left}, ${margin.top})`);

    const canvas = container
      .append("canvas")
      .attr("width", innerWidth * dpi)
      .attr("height", innerHeight * dpi)
      .style("width", `${innerWidth}px`)
      .style("position", "absolute")
      .style("top", `${margin.top}px`)
      .style("left", `${margin.left}px`);

    const context = canvas.node().getContext("2d");
    context.scale(dpi, dpi);

    // Setup rtree
    const tree = new RBush();

    // Currently selected node
    let selectedNode;

    this.handleEvent("summaries", ({ summaries }) => {
      const data = summaries.filter((d) => d.type === "Run");

      // X range (velocity low to high)
      const x = d3
        .scaleLinear()
        .domain(d3.extent(data, (d) => d.velocity))
        .range([0, innerWidth]);

      const minX = d3.min(data.map((d) => d.velocity));
      const maxX = d3.max(data.map((d) => d.velocity));

      const xAxis = (g) => g.call(d3.axisTop(x).tickFormat((d) => `${d} mps`));
      wrapper.append("g").call(xAxis);

      // Y range (each year)
      // const y = d3
      //   .scaleLinear()
      //   .domain(d3.extent(data, (d) => d.year))
      //   .range([0, innerHeight]);

      // Y range (just "All")
      const y = d3.scaleBand().domain(["All Runs"]).range([0, innerHeight]);

      const yAxis = (g) =>
        g
          .call(d3.axisLeft(y))
          .call((g) => g.select(".domain").remove())
          .call((g) => g.selectAll(".tick line").remove());
      wrapper.append("g").call(yAxis);

      // Radius range (map distance to 1-10)
      const r = d3
        .scaleSqrt()
        .domain(d3.extent(data, (d) => d.distance))
        .range([1, 10]);

      // Color range (faster is yellow, slower is black)
      const color = d3.scaleSequential(
        d3.extent(data, (d) => d.velocity),
        d3.interpolateMagma
      );

      // Force simulation with collision detection
      const simulation = d3
        .forceSimulation(data)
        .velocityDecay(0.2)
        .force(
          "x",
          d3.forceX((d) => x(d.velocity))
        )
        .force(
          "y",
          d3.forceY(() => innerHeight / 2)
        )
        .force(
          "collide",
          d3
            .forceCollide()
            .radius((d) => r(d.distance) + 1)
            .iterations(2)
        )
        .on("tick", ticked);

      // Handle mousemove events
      canvas.on("mousemove", function (event) {
        const [x, y] = d3.pointer(event);

        // Search rtree for the intersection
        const result = tree.search({
          minX: x,
          minY: y,
          maxX: x,
          maxY: y,
        });

        // Set the selected node if it exists
        selectedNode = result[0]?.slug;

        // Change to pointer
        document.body.style.cursor = result[0] ? "pointer" : "auto";

        // If the simulation has finished, then redraw
        // No need to redraw if we are still animating
        if (simulation.alpha() <= simulation.alphaMin()) {
          draw();
        }
      });

      // Draw each circle using arc and fill
      function draw() {
        context.clearRect(0, 0, innerWidth, innerHeight);
        context.save();

        for (const d of data) {
          context.beginPath();
          context.moveTo(d.x + r(d.distance), d.y);
          context.arc(d.x, d.y, r(d.distance), 0, 2 * Math.PI);
          context.fillStyle =
            d.slug === selectedNode ? "#fff" : color(d.velocity);
          context.fill();
        }
        context.restore();
      }

      function buildBBox() {
        tree.clear();

        // Build bounding boxes for each node
        const nodes = data.map((d) => {
          return {
            ...d,
            minX: d.x - r(d.distance),
            maxX: d.x + r(d.distance),
            minY: d.y - r(d.distance),
            maxY: d.y + r(d.distance),
          };
        });

        tree.load(nodes);
      }

      function ticked() {
        draw();

        // Building the bounding box each render may be too slow
        // If it is too slow, I can see that the simulation is done rendering
        // simulation.alpha() <= simulation.alphaMin()
        buildBBox();
      }
    });
  },
};
