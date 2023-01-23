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
  updateChart(year) {
    if (!this.chart) {
      return;
    }

    if (year) {
      const d1 = new Date(year, 0, 1);
      const d2 = new Date(year, 11, 31);

      this.x.domain([d1, d2]);
    } else {
      this.x.domain(d3.extent(this.data, (d) => d.date));
    }

    const line = d3
      .line()
      .curve(d3.curveBasis)
      .x((d) => this.x(d.date))
      .y((d) => this.y(d.amount));

    // Update line position
    this.chart.select(".line").transition().duration(1000).attr("d", line);
  },
  mounted() {
    const field = this.el.dataset["field"];

    this.handleEvent("update-year", ({ year }) => {
      this.updateChart(year);
    });

    this.handleEvent("summaries", ({ summaries }) => {
      // Filter for only runs
      const data = summaries.filter((d) => d.type === "Run");

      // totals for each metric
      let total;

      if (field === "count") {
        total = data.length;
      } else if (field === "duration") {
        total = d3.sum(data, (d) => d.duration) / 60 / 60;
      } else {
        total = d3.sum(data, (d) => d[field]);
      }

      // Animate the sums of various activity related figures
      this.animateAmount(total);

      // Iterate once through all the run activities
      const sumsByMonth = data.reduce((obj, d) => {
        const date = DateTime.fromISO(d.start_at_local).startOf("month");
        const dateStr = date.toISODate();

        obj[dateStr] ||= 0;

        if (field === "count") {
          obj[dateStr] += 1;
        } else if (field === "duration") {
          obj[dateStr] += d.duration / 60 / 60;
        } else {
          obj[dateStr] += d[field];
        }

        return obj;
      }, {});

      const dataByMonth = Object.keys(sumsByMonth).map((key) => {
        return {
          amount: sumsByMonth[key],
          date: new Date(key),
        };
      });

      this.data = dataByMonth;

      this.lineChart(dataByMonth);

      document.addEventListener("showTooltip", (e) => {
        const nearestDate = e.detail;
        // this.chart.setTooltipPosition(nearestDate);
      });

      document.addEventListener("graphMouseOut", () => {
        // this.chart.mouseOut();
      });

      document.addEventListener("graphMouseOver", () => {
        // this.chart.mouseOver();
      });
    });
  },

  animateAmount(amount) {
    const text = d3.select(this.el.querySelector(".total-amount"));

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

  lineChart(data) {
    const el = this.el;
    const container = d3.select(this.el.querySelector(".mini-chart"));
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
      obj[dateStr] = d.amount;
      return obj;
    }, {});

    const x = d3
      .scaleTime()
      .domain(d3.extent(data, (d) => d.date))
      .range([0 + margin.left, width - margin.right]);

    this.x = x;

    const y = d3
      .scaleLinear()
      .domain([0, d3.max(data, (d) => d.amount)])
      .nice()
      .range([height - margin.top, 0 + margin.bottom]);

    this.y = y;

    const svg = container
      .append("svg")
      .attr("viewBox", [0, 0, width, height])
      .on("mousemove", focusMouseMove)
      .on("mouseover", focusMouseOver)
      .on("mouseout", focusMouseOut);

    this.chart = svg
      .append("g")
      .attr("transform", `translate(${margin.left}, ${margin.top})`);

    /* GRADIENT AREA CHART */
    const area = d3
      .area()
      .curve(d3.curveBasis)
      .x((d) => x(d.date))
      .y1((d) => y(d.amount))
      .y0((d) => y(0));

    const gradient = this.chart
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

    this.chart
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
      .y((d) => y(d.amount));

    this.chart
      .append("path")
      .datum(data)
      .attr("class", "line") // I add the class line to be able to modify this line later on.
      .attr("fill", "none")
      .attr("stroke", "white")
      .attr("stroke-width", 1.5)
      .attr("d", line);
    /* END OF LINE CHART */

    const mouseLine = this.chart
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
      const e = new CustomEvent("graphMouseOut");
      document.dispatchEvent(e);
    }

    function focusMouseOver(event) {
      const e = new CustomEvent("graphMouseOver");
      document.dispatchEvent(e);
      mouseLine.attr("opacity", "1");
    }

    function focusMouseMove(event) {
      const mouse = d3.pointer(event);
      const nearestDate = x.invert(mouse[0]);

      const beginningOfMonth =
        DateTime.fromJSDate(nearestDate).startOf("month");

      const e = new CustomEvent("showTooltip", { detail: beginningOfMonth });
      document.dispatchEvent(e);
    }

    function setTooltipPosition(nearestDate) {
      const nearestXCord = x(nearestDate.toJSDate());
      const dateStr = nearestDate.toISODate();
      const value = dataMap[dateStr] || 0;

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
