import * as d3 from "d3";

export default {
  mounted() {
    // set the dimensions and margins of the graph
    const margin = { top: 30, right: 30, left: 30, bottom: 30 };
    const container = d3.select(this.el);

    // Get the height and width from the container element
    const width = this.el.clientWidth;
    const height = this.el.clientHeight;

    // Create the svg and append it to the container
    const svg = container
      .append("svg")
      .attr("width", width)
      .attr("height", height)
      .attr("viewBox", [0, 0, width, height])
      .attr("style", "max-width: 100%; height: auto; height: intrinsic;");

    this.handleEvent("laps", ({ laps }) => {
      const totalTime = d3.sum(laps, (d) => d.elapsed_time);
      const totalDistance = d3.sum(laps, (d) => d.distance);

      // const xValues = laps.map((d) => d.elapsed_time);
      const xValues = laps.map((d) => d.distance);
      const yValues = laps.map((d) => d.average_speed);
      console.log(xValues);

      const x = d3
        .scaleLinear()
        .domain([0, totalDistance])
        .range([margin.left, width - margin.right]);

      const y = d3
        .scaleLinear()
        .domain([d3.max(yValues), 0])
        .nice()
        .range([margin.top, height - margin.bottom]);

      const xAxis = (g) => g.call(d3.axisBottom(x));
      svg
        .append("g")
        .attr("transform", `translate(0, ${height - margin.bottom})`)
        .call(xAxis);

      const yAxis = (g) => g.call(d3.axisLeft(y));
      svg
        .append("g")
        .attr("transform", `translate(${margin.left}, 0)`)
        .call(yAxis);

      const bar = svg
        .append("g")
        .attr("fill", "#fb6340")
        .selectAll("rect")
        .data(laps)
        .join("rect")
        .attr("x", (d, idx) => {
          let values = [0, ...xValues];
          values = values.map((value, index) =>
            values.slice(0, index + 1).reduce((a, b) => a + b)
          );
          return x(values[idx]) + 1;
        })
        .attr("y", (d) => y(d.average_speed))
        .attr("height", (d) => y(0) - y(d.average_speed))
        .attr("width", (d) => x(d.distance) - x(0) - 2);
    });
  },
};
