import * as d3 from "d3";

/*
 * ActivityBubbleChart Hook
 * D3 chart based on https://observablehq.com/@ch-bu/bubble-chart-split-my-running-by-year
 * Rewritten using canvas to be more performant for the force animations
 * TODO: Tooltips using picking see https://medium.com/free-code-camp/d3-and-canvas-in-3-steps-8505c8b27444
 * Animation on hover
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

    const canvas = container
      .append("canvas")
      .attr("width", width * dpi)
      .attr("height", height * dpi)
      .style("width", `${width}px`);

    const context = canvas.node().getContext("2d");
    context.scale(dpi, dpi);

    this.handleEvent("summaries", ({ summaries }) => {
      const data = summaries.filter((d) => d.type === "Run");

      // X range (velocity low to high)
      const x = d3
        .scaleLinear()
        .domain(d3.extent(data, (d) => d.velocity))
        .range([margin.left, margin.left + innerWidth]);

      // Y range (each year)
      const y = d3
        .scaleLinear()
        .domain(d3.extent(data, (d) => d.year))
        .range([margin.top, height - margin.bottom]);

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

      function ticked() {
        context.clearRect(0, 0, width, height);
        context.save();

        for (const d of data) {
          context.beginPath();
          context.moveTo(d.x + r(d.distance), d.y);
          context.arc(d.x, d.y, r(d.distance), 0, 2 * Math.PI);
          context.fillStyle = color(d.velocity);
          context.fill();
        }
        context.restore();
      }
    });
  },
};
