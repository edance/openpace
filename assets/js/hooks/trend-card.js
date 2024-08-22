import * as d3 from "d3";
import { DateTime } from "luxon";
import { formatNumber } from "../utils";

const ANIMATION_DURATION = 1000;

function formatDate(date) {
  return new Intl.DateTimeFormat("en-US", {
    month: "short",
    year: "numeric",
  }).format(date);
}

export default {
  setXDomain() {
    if (this.year) {
      const d1 = DateTime.utc()
        .set({ year: this.year })
        .startOf("year")
        .toJSDate();
      const d2 = DateTime.utc()
        .set({ year: this.year })
        .endOf("year")
        .toJSDate();

      this.x.domain([d1, d2]);
    } else {
      this.x.domain(d3.extent(this.dataByMonth, (d) => d.date));
    }
  },

  setYDomain() {
    this.y.domain([0, d3.max(this.dataByMonth, (d) => d.amount)]);
  },

  calculateTotal() {
    const filteredData = this.year
      ? this.data.filter(
          (d) =>
            DateTime.fromISO(d.start_at_local).year === parseInt(this.year, 10)
        )
      : this.data;

    if (this.field === "count") {
      this.total = filteredData.length;
    } else if (this.field === "duration") {
      this.total = d3.sum(filteredData, (d) => d.duration) / 60 / 60;
    } else {
      this.total = d3.sum(filteredData, (d) => d[this.field]);
    }
  },
  updateChart() {
    if (!this.chart) {
      return;
    }

    this.setXDomain();
    this.setYDomain();

    // Update line position
    this.chart
      .select(".line")
      .transition()
      .duration(ANIMATION_DURATION)
      .attr("d", this.line);

    // Update line gradient
    this.chart
      .select(".line-gradient")
      .transition()
      .duration(ANIMATION_DURATION)
      .attr("d", this.area);
  },

  mounted() {
    this.field = this.el.dataset["field"];
    this.data = [];
    this.year = null;
    this.handleEvent("update-year", ({ year }) => {
      this.year = year;

      this.updateChart();

      // Animate the sums of various activity related figures
      this.animateAmount();
    });

    this.handleEvent("summaries", ({ summaries }) => {
      // Filter for only runs
      this.data = summaries.filter((d) => d.activity_type === "run");

      // Animate the sums of various activity related figures
      this.animateAmount();

      // Iterate once through all the run activities
      const sumsByMonth = this.data.reduce((obj, d) => {
        const date = DateTime.fromISO(d.start_at_local).startOf("month");
        const dateStr = date.toISODate();

        obj[dateStr] ||= 0;

        if (this.field === "count") {
          obj[dateStr] += 1;
        } else if (this.field === "duration") {
          obj[dateStr] += d.duration / 60 / 60;
        } else {
          obj[dateStr] += d[this.field];
        }

        return obj;
      }, {});

      this.dataByMonth = Object.keys(sumsByMonth).map((key) => {
        return {
          amount: sumsByMonth[key],
          date: new Date(key),
        };
      });

      const { setTooltipPosition, mouseOut, mouseOver } = this.createChart();

      document.addEventListener("showTooltip", (e) => {
        const nearestDate = e.detail;
        setTooltipPosition(nearestDate);
      });

      document.addEventListener("graphMouseOut", () => {
        mouseOut();
      });

      document.addEventListener("graphMouseOver", () => {
        mouseOver();
      });
    });
  },

  animateAmount() {
    const selection = d3.select(this.el.querySelector(".total-amount"));

    this.calculateTotal();

    selection
      .transition()
      .tween("text", () => {
        // start value prior to transition without commas
        const start = parseInt(selection.text().replace(/,/g, ""), 10);

        // From start to amount
        const interpolator = d3.interpolateNumber(start, this.total);

        return function (t) {
          selection.text(formatNumber(interpolator(t)));
        };
      })
      .duration(ANIMATION_DURATION);
  },

  createGradient() {
    this.area = d3
      .area()
      .curve(d3.curveLinear)
      .x((d) => this.x(d.date))
      .y1((d) => this.y(d.amount))
      .y0((d) => this.y(0));

    const gradId = `${this.field}-grad`;

    const gradient = this.chart
      .append("defs")
      .append("linearGradient")
      .attr("id", gradId) // defining an id
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
      .datum(this.dataByMonth)
      .attr("class", "line-gradient")
      .attr("d", this.area)
      .style("fill", `url(#${gradId})`); // assigning to defined id
  },

  createLine() {
    this.line = d3
      .line()
      .curve(d3.curveLinear)
      .x((d) => this.x(d.date))
      .y((d) => this.y(d.amount));

    this.chart
      .append("path")
      .datum(this.dataByMonth)
      .attr("class", "line")
      .attr("fill", "none")
      .attr("stroke", "white")
      .attr("stroke-width", 1.5)
      .attr("d", this.line);
  },

  createChart() {
    const label = this.el.querySelector(".amount-label").innerText;
    const container = d3.select(this.el.querySelector(".mini-chart"));
    const margin = { top: 30, right: 0, left: 0, bottom: 0 };

    // Get the height and width from the container element
    const width = container.node().clientWidth;
    const height = container.node().clientHeight;

    // Inner section
    const innerWidth = width - margin.left - margin.right;
    const innerHeight = height - margin.top - margin.bottom;

    const dataMap = this.dataByMonth.reduce((obj, d) => {
      const date = DateTime.fromJSDate(d.date, { zone: "utc" });
      const dateStr = date.toISODate();
      obj[dateStr] = d.amount;
      return obj;
    }, {});

    // create X scale and set domain
    this.x = d3.scaleTime().range([0 + margin.left, width - margin.right]);
    this.setXDomain();

    // create Y scale and set domain
    this.y = d3.scaleLinear().range([height - margin.top, 0 + margin.bottom]);
    this.setYDomain();

    const svg = container.append("svg").attr("viewBox", [0, 0, width, height]);

    this.chart = svg
      .append("g")
      .attr("transform", `translate(${margin.left}, ${margin.top})`);

    this.createGradient();
    this.createLine();

    const mouseLine = this.chart
      .append("path") // create vertical line to follow mouse
      .attr("class", "mouse-line")
      .attr("stroke", "white")
      .attr("stroke-width", 2)
      .attr("opacity", "0");

    const tooltip = container
      .append("div")
      .attr("class", "tooltip show absolute bg-gray-900 text-white rounded-lg shadow-lg px-2 py-1 flex items-center justify-center text-sm min-w-24")
      .style("display", "none");
    const tooltipInner = tooltip.append("div");
    const tooltipDate = tooltipInner.append("strong");
    const tooltipValue = tooltipInner.append("div");

    const focusMouseOut = () => {
      const e = new CustomEvent("graphMouseOut");
      document.dispatchEvent(e);
    };

    const focusMouseOver = (event) => {
      const e = new CustomEvent("graphMouseOver");
      document.dispatchEvent(e);
      mouseLine.attr("opacity", "1");
    };

    const focusMouseMove = (event) => {
      const mouse = d3.pointer(event);
      const nearestDate = this.x.invert(mouse[0]);

      const beginningOfMonth =
        DateTime.fromJSDate(nearestDate).startOf("month");

      const e = new CustomEvent("showTooltip", { detail: beginningOfMonth });
      document.dispatchEvent(e);
    };

    const setTooltipPosition = (nearestDate) => {
      const nearestXCord = this.x(nearestDate.toJSDate());
      const dateStr = nearestDate.toISODate();
      const value = dataMap[dateStr] || 0;

      mouseLine
        .attr("d", `M ${nearestXCord} 0 V ${height}`)
        .attr("opacity", "1");

      tooltipDate.text(formatDate(nearestDate.toJSDate()));
      tooltipValue.text(`${formatNumber(value)} ${label}`);

      const tooltipWidth = tooltip.node().clientWidth;
      const tooltipHeight = tooltip.node().clientHeight;

      tooltip
        .style("bottom", `${innerHeight + 10}px`)
        .style("left", `${nearestXCord - tooltipWidth / 2}px`)
        .style("display", null);
    };

    function mouseOut() {
      mouseLine.attr("opacity", "0");
      tooltip.style("display", "none");
    }

    function mouseOver() {
      mouseLine.attr("opacity", "1");
      tooltip.style("display", null);
    }

    svg
      .on("mousemove", focusMouseMove)
      .on("mouseover", focusMouseOver)
      .on("mouseout", focusMouseOut);

    return {
      setTooltipPosition,
      mouseOut,
      mouseOver,
    };
  },
};
