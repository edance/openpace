import * as d3 from "d3";
import { calcDistance, range, pad, roundTo } from "../utils";

function velocityToPace(velocity, imperial) {
  const distance = imperial ? 1609 : 1000; // Mile or kilometer
  return distance / 60 / velocity;
}

export default {
  // Returns speed (kph/mph) or pace (min/km or min/mile)
  speedOrPace(velocity) {
    const distance = this.imperial ? 1609 : 1000; // Mile or kilometer

    if (this.activityType === "run") {
      return distance / 60 / velocity;
    } else {
      return (velocity * 60 * 60) / distance;
    }
  },
  yTick(value) {
    if (this.activityType === "run") {
      const min = Math.floor(value);
      const sec = Math.round((value - min) * 60);
      const label = this.imperial ? "/mi" : "/km";

      return `${min}:${pad(sec)}${label}`;
    } else {
      const label = this.imperial ? "mph" : "kph";
      return `${roundTo(value, 1)}${label}`;
    }
  },
  mounted() {
    this.imperial = JSON.parse(this.el.dataset["imperial"]);
    this.activityType = this.el.dataset["type"];

    // set the dimensions and margins of the graph
    const margin = { top: 30, right: 30, left: 70, bottom: 30 };
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
      if (!laps?.length) {
        return;
      }

      const xValues = laps.map((d) =>
        calcDistance(d.distance, this.imperial, 2)
      );
      const yValues = laps.map((d) => this.speedOrPace(d.average_speed));
      const totalDistance = d3.sum(xValues);
      const minPace = Math.floor(d3.min(yValues));
      const maxPace = Math.ceil(d3.max(yValues));
      const yPadding = (maxPace - minPace) / 2;

      const x = d3
        .scaleLinear()
        .domain([0, totalDistance])
        .range([margin.left, width - margin.right]);

      const y = d3
        .scaleLinear()
        .domain([minPace - yPadding, maxPace + yPadding])
        .range([margin.top, height - margin.bottom]);

      // Color range (faster is yellow, slower is black)
      const color = d3.scaleSequential(
        d3.extent(laps, (d) => d.average_speed),
        d3.interpolateMagma
      );

      const xAxis = (g) => g.call(d3.axisBottom(x));
      svg
        .append("g")
        .attr("transform", `translate(0, ${height - margin.bottom})`)
        .call(xAxis);

      const yAxis = (g) =>
        g.call(
          d3
            .axisLeft(y)
            .tickValues(range(minPace, maxPace))

            .tickFormat((d) => this.yTick(d))
        );
      svg
        .append("g")
        .attr("transform", `translate(${margin.left}, 0)`)
        .call(yAxis);

      const bars = svg
        .append("g")
        .selectAll("rect")
        .data(laps)
        .join("rect")
        .attr("fill", (d) => color(d.average_speed))
        .attr("fill-opacity", 0.5)
        .attr("x", (d, idx) => {
          let values = [0, ...xValues];
          values = values.map((value, index) =>
            values.slice(0, index + 1).reduce((a, b) => a + b)
          );
          return x(values[idx]) + 1;
        })
        .attr("y", (d, i) => y(yValues[i]))
        .attr("height", (d, i) => y(maxPace + yPadding) - y(yValues[i]))
        .attr("width", (d, i) => x(xValues[i]) - x(0) - 2);
    });
  },
};
