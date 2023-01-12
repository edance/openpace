import * as d3 from "d3";
import { DateTime } from "luxon";
import { formatNumber } from "../utils";

export default {
  mounted() {
    this.handleEvent("summaries", ({ summaries }) => {
      const data = summaries.filter((d) => d.type === "Run");

      const totalDistance = d3.sum(data, (d) => d.distance);
      const totalDuration = d3.sum(data, (d) => d.duration) / 60 / 60;
      const elevationGain = d3.sum(data, (d) => d.elevation_gain);
      const runCount = data.length;

      // Animate the sums of various activity related figures
      this.animateAmount("#total-distance", totalDistance);
      this.animateAmount("#total-duration", totalDuration);
      this.animateAmount("#elevation-gain", elevationGain);
      this.animateAmount("#run-count", runCount);

      // Iterate once through all the run activities
      // sum up the distance, duration, elevation, and run count for each month
      const sumsByMonth = data.reduce((obj, d) => {
        const date = DateTime.fromISO(d.start_at_local).startOf("month");
        const dateStr = date.toISODate();

        const item = obj[dateStr] || {
          distance: 0,
          duration: 0,
          elevationGain: 0,
          runCount: 0,
        };

        item.distance += d.distance;
        item.duration += d.duration;
        item.elevationGain += d.elevation_gain;
        item.runCount += 1;

        obj[dateStr] = item;

        return obj;
      }, {});

      const dataByMonth = Object.keys(sumsByMonth).map((key) => {
        return {
          ...sumsByMonth[key],
          date: new Date(key),
        };
      });

      this.lineChart("#total-distance-chart", dataByMonth, "distance");
      this.lineChart("#total-duration-chart", dataByMonth, "duration");
      this.lineChart("#total-elevation-chart", dataByMonth, "elevationGain");
      this.lineChart("#run-count-chart", dataByMonth, "runCount");
    });
  },

  animateAmount(id, amount) {
    const text = d3.select(id);

    text
      .transition()
      .tween("text", function () {
        const selection = d3.select(this); // selection of node being transitioned
        const interpolator = d3.interpolateNumber(0, amount); // d3 interpolator

        return function (t) {
          selection.text(formatNumber(interpolator(t)));
        }; // return value
      })
      .duration(1000);
  },

  lineChart(id, data, field) {
    const container = d3.select(id);
    const width = container.node().clientWidth;
    const height = width / 6;

    const x = d3
      .scaleTime()
      .domain(d3.extent(data, (d) => d.date))
      .range([0, width]);

    const y = d3
      .scaleLinear()
      .domain([0, d3.max(data, (d) => d[field])])
      .nice()
      .range([height, 0]);

    const svg = container.append("svg").attr("viewBox", [0, 0, width, height]);

    /* GRADIENT AREA CHART */
    const area = d3
      .area()
      .curve(d3.curveBasis)
      .x((d) => x(d.date))
      .y1((d) => y(d[field]))
      .y0((d) => y(0));

    const gradient = svg
      .append("defs")
      .append("linearGradient")
      .attr("id", "mygrad") // defining an id
      .attr("x1", "0%")
      .attr("x2", "0%")
      .attr("y1", "0%")
      .attr("y2", "100%");

    gradient
      .append("stop")
      .attr("offset", "0%")
      .style("stop-color", "white")
      .style("stop-opacity", 0.3);

    gradient
      .append("stop")
      .attr("offset", "100%")
      .style("stop-color", "white")
      .style("stop-opacity", 0.0);

    svg
      .append("path")
      .datum(data)
      .attr("d", area)
      .style("fill", "url(#mygrad)"); // assigning to defined id
    /* END OF GRADIENT AREA CHART */

    /* LINE CHART */
    const line = d3
      .line()
      .curve(d3.curveBasis)
      .x((d) => {
        if (isNaN(d.date)) {
          debugger;
        }
        return x(d.date);
      })
      .y((d) => y(d[field]));

    svg
      .append("path")
      .datum(data)
      .attr("fill", "none")
      .attr("stroke", "white")
      .attr("stroke-width", 1.5)
      .attr("d", line);
    /* END OF LINE CHART */
  },
};
