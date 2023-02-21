import * as d3 from "d3";
import RBush from "rbush";
import { pad } from "../utils";

function velocityToFormattedPace(velocity, imperial = false) {
  const distance = imperial ? 1609 : 1000; // Mile or kilometer
  const label = imperial ? "/mi" : "/km";

  const min = Math.floor(distance / 60 / velocity);
  const sec = Math.round(distance / velocity - min * 60);

  return `${min}:${pad(sec)}${label}`;
}

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

    const imperial = JSON.parse(this.el.dataset["imperial"]);

    // Get the height and width from the container element
    const width = this.el.clientWidth;
    const height = this.el.clientHeight;

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
      .attr("width", width * dpi)
      .attr("height", height * dpi)
      .style("width", `${width}px`)
      .style("position", "absolute")
      .style("top", "0px")
      .style("left", "0px");

    const context = canvas.node().getContext("2d");
    context.scale(dpi, dpi);

    // Setup rtree
    const tree = new RBush();

    // Currently selected node
    let selectedNode;

    this.handleEvent("summaries", ({ summaries }) => {
      const data = summaries.filter((d) => d.activity_type === "run");

      // X range (velocity low to high)
      const x = d3
        .scaleLinear()
        .domain(d3.extent(data, (d) => d.velocity))
        .nice()
        .range([margin.left, width - margin.right]);

      const xAxis = (g) =>
        g
          .call(
            d3
              .axisTop(x)
              .tickFormat((d) => `${velocityToFormattedPace(d, imperial)}`)
          )
          .call((g) => g.select(".domain").remove())
          .call((g) =>
            g
              .append("text")
              .attr("x", width - margin.right)
              .attr("y", 20)
              .attr("font-weight", "bold")
              .attr("fill", "currentColor")
              .attr("text-anchor", "end")
              .text("Running Faster →")
          );

      svg
        .append("g")
        .attr("transform", `translate(0, ${margin.top})`)
        .call(xAxis);

      // Y range (each year)
      // const y = d3
      //   .scaleLinear()
      //   .domain(d3.extent(data, (d) => d.year))
      //   .range([0, height]);

      // Y range (just "All")
      const y = d3.scaleBand().domain(["All Runs"]).range([0, height]);

      const yAxis = (g) =>
        g
          .call(d3.axisLeft(y))
          .call((g) => g.select(".domain").remove())
          .call((g) => g.selectAll(".tick line").remove());
      svg
        .append("g")
        .attr("transform", `translate(${margin.left}, 0)`)
        .call(yAxis);

      // Add median speed
      const median = d3.median(data, (d) => d.velocity);
      const medianLine = svg
        .append("line")
        .attr("x1", x(median))
        .attr("x2", x(median))
        .attr("y1", margin.top)
        .attr("y2", height - margin.bottom)
        .attr("stroke", "#ccc");

      // Add median text
      const medianText = svg
        .append("text")
        .attr("x", x(median) + 5)
        .attr("y", height - margin.bottom + 0)
        .attr("font-weight", "bold")
        .attr("fill", "currentColor")
        .attr("font-size", "11px")
        .text(`Median pace: ${velocityToFormattedPace(median, imperial)}`);

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
          d3.forceY(() => height / 2)
        )
        .force(
          "collide",
          d3
            .forceCollide()
            .radius((d) => r(d.distance) + 1)
            .iterations(2)
        )
        .on("tick", ticked);

      window.force = simulation;

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

        // console.log("selectedNode", result[0]);

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
        context.clearRect(0, 0, width, height);
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
