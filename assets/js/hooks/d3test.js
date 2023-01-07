import * as d3 from "d3";

export default {
  mounted() {
    // set the dimensions and margins of the graph
    const margin = { top: 30, right: 30, left: 120, bottom: 30 };
    const width = 1000;
    const height = 500;
    const innerWidth = width - margin.left - margin.right;
    const innerHeight = height - margin.top - margin.bottom;

    const container = d3.select(this.el);

    const svg = container.append("svg").attr("viewBox", [0, 0, width, height]);

    const wrapper = svg
      .append("g")
      .attr("transform", `translate(${margin.left}, ${margin.top})`);

    this.handleEvent("summaries", ({ summaries }) => {
      const data = summaries
        .filter((d) => d.type === "Run")
        .map((d) => {
          const speed = d.distance / d.duration; // meters per second

          return {
            ...d,
            distance: d.distance / 1609,
            start_at_local: new Date(d.start_at_local),
            year: new Date(d.start_at_local).getFullYear(),
            speed,
            pace: 1609 / 60 / speed,
          };
        });

      const x = d3
        .scaleLinear()
        .domain(d3.extent(data, (d) => d.speed))
        .range([0, innerWidth]);

      const xAxis = (g) => g.call(d3.axisTop(x).tickFormat((d) => `${d} mps`));
      wrapper.append("g").call(xAxis);

      const r = d3
        .scaleSqrt()
        .domain(d3.extent(data, (d) => d.distance))
        .range([1, 10]);

      const color = d3.scaleSequential(
        d3.extent(data, (d) => d.speed),
        d3.interpolateMagma
      );

      const circles = wrapper
        .append("g")
        .attr("className", "circles")
        .selectAll("circle")
        .data(data)
        .join("circle")
        .attr("r", (d) => r(d.distance))
        .attr("fill", (d) => color(d.speed))
        .attr("s", (d) => d.slug)
        .attr("x", (d) => x(d.speed))
        .attr("y", (d) => innerHeight / 2);

      const force = d3
        .forceSimulation(data)
        .force("charge", d3.forceManyBody().strength(0))
        .force(
          "x",
          d3.forceX().x((d) => x(d.speed))
        )
        .force(
          "y",
          d3.forceY((d) => innerHeight / 2)
        )
        .force(
          "collision",
          d3.forceCollide().radius((d) => r(d.distance) + 1)
        );

      force.on("tick", () => {
        circles
          // .transition()
          // .ease(d3.easeLinear)
          .attr("cx", (d) => d.x)
          .attr("cy", (d) => d.y);
      });

      // Disable the animation
      while (force.alpha() > force.alphaMin()) {
        force.tick();
      }
    });
  },
};
