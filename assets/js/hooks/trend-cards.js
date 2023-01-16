import * as d3 from "d3";
import { DateTime } from "luxon";
import { formatNumber } from "../utils";

function formatDate(date) {
  return new Intl.DateTimeFormat("en-US", {
    month: "short",
    year: "numeric",
  }).format(date);
}

export default {
  mounted() {
    this.handleEvent("summaries", ({ summaries }) => {
      // Filter for only runs
      const data = summaries.filter((d) => d.type === "Run");

      // totals for each metric
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
        item.duration += d.duration / 60 / 60;
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

      const distanceChart = this.lineChart(
        "#total-distance-chart",
        dataByMonth,
        "distance"
      );
      const durationChart = this.lineChart(
        "#total-duration-chart",
        dataByMonth,
        "duration"
      );
      const elevationChart = this.lineChart(
        "#total-elevation-chart",
        dataByMonth,
        "elevationGain"
      );
      const runCountChart = this.lineChart(
        "#run-count-chart",
        dataByMonth,
        "runCount"
      );

      this.el.addEventListener("showTooltip", (e) => {
        const nearestDate = e.detail;

        distanceChart.setTooltipPosition(nearestDate);
        durationChart.setTooltipPosition(nearestDate);
        elevationChart.setTooltipPosition(nearestDate);
        runCountChart.setTooltipPosition(nearestDate);
      });

      this.el.addEventListener("mouseOut", () => {
        distanceChart.mouseOut();
        durationChart.mouseOut();
        elevationChart.mouseOut();
        runCountChart.mouseOut();
      });

      this.el.addEventListener("mouseOver", () => {
        distanceChart.mouseOver();
        durationChart.mouseOver();
        elevationChart.mouseOver();
        runCountChart.mouseOver();
      });
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
    const el = this.el;
    const container = d3.select(id);
    const margin = { top: 30, right: 0, left: 0, bottom: 0 };

    // Get the height and width from the container element
    const width = container.node().clientWidth;
    const height = container.node().clientHeight;

    // Inner section
    const innerWidth = width - margin.left - margin.right;
    const innerHeight = height - margin.top - margin.bottom;

    const dataMap = data.reduce((obj, d) => {
      const date = DateTime.fromJSDate(d.date, { zone: "utc" });
      const dateStr = date.toISODate();
      obj[dateStr] = d[field];
      return obj;
    }, {});

    const x = d3
      .scaleTime()
      .domain(d3.extent(data, (d) => d.date))
      .range([0 + margin.left, width - margin.right]);

    const y = d3
      .scaleLinear()
      .domain([0, d3.max(data, (d) => d[field])])
      .nice()
      .range([height - margin.top, 0 + margin.bottom]);

    const svg = container
      .append("svg")
      .attr("viewBox", [0, 0, width, height])
      .on("mousemove", focusMouseMove)
      .on("mouseover", focusMouseOver)
      .on("mouseout", focusMouseOut);

    const chart = svg
      .append("g")
      .attr("transform", `translate(${margin.left}, ${margin.top})`);

    /* GRADIENT AREA CHART */
    const area = d3
      .area()
      .curve(d3.curveBasis)
      .x((d) => x(d.date))
      .y1((d) => y(d[field]))
      .y0((d) => y(0));

    const gradient = chart
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

    chart
      .append("path")
      .datum(data)
      .attr("d", area)
      .style("fill", "url(#mygrad)"); // assigning to defined id
    /* END OF GRADIENT AREA CHART */

    /* LINE CHART */
    const line = d3
      .line()
      .curve(d3.curveBasis)
      .x((d) => x(d.date))
      .y((d) => y(d[field]));

    chart
      .append("path")
      .datum(data)
      .attr("fill", "none")
      .attr("stroke", "white")
      .attr("stroke-width", 1.5)
      .attr("d", line);
    /* END OF LINE CHART */

    const mouseLine = chart
      .append("path") // create vertical line to follow mouse
      .attr("class", "mouse-line")
      .attr("stroke", "white")
      .attr("stroke-width", 2)
      .attr("opacity", "0");

    const tooltip = container
      .append("div")
      .attr("class", "tooltip show")
      .style("display", "none");
    const tooltipInner = tooltip.append("div").attr("class", "tooltip-inner");
    const tooltipDate = tooltipInner.append("strong");
    const tooltipValue = tooltipInner.append("div");

    function focusMouseOut() {
      const e = new CustomEvent("mouseOut");
      el.dispatchEvent(e);
    }

    function focusMouseOver(event) {
      const e = new CustomEvent("mouseOver");
      el.dispatchEvent(e);
      mouseLine.attr("opacity", "1");
    }

    function focusMouseMove(event) {
      const mouse = d3.pointer(event);
      const nearestDate = x.invert(mouse[0]);

      const beginningOfMonth =
        DateTime.fromJSDate(nearestDate).startOf("month");

      const e = new CustomEvent("showTooltip", { detail: beginningOfMonth });
      el.dispatchEvent(e);
    }

    function setTooltipPosition(nearestDate) {
      const nearestXCord = x(nearestDate.toJSDate());
      const dateStr = nearestDate.toISODate();
      const value = dataMap[dateStr];

      mouseLine
        .attr("d", `M ${nearestXCord} 0 V ${height}`)
        .attr("opacity", "1");

      tooltipDate.text(formatDate(nearestDate.toJSDate()));
      tooltipValue.text(formatNumber(value));

      const tooltipWidth = tooltip.node().clientWidth;
      const tooltipHeight = tooltip.node().clientHeight;

      tooltip
        .style("bottom", `${innerHeight + 10}px`)
        .style("left", `${nearestXCord - tooltipWidth / 2}px`)
        .style("display", null);
    }

    function mouseOut() {
      mouseLine.attr("opacity", "0");
      tooltip.style("display", "none");
    }

    function mouseOver() {
      mouseLine.attr("opacity", "1");
      tooltip.style("display", null);
    }

    return {
      setTooltipPosition,
      mouseOut,
      mouseOver,
    };
  },
};
