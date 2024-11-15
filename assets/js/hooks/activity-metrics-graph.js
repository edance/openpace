import * as d3 from "d3";
import {
  formatVelocity,
  formatDuration,
  isDarkMode,
  formatTemperature,
  formatAltitude,
  formatDistance,
} from "../utils";
import { colors, fonts } from "./../variables.js";

export default {
  metrics: {
    altitude: {
      color: "#FF9800",
      label: "Altitude",
      visible: true,
      gradient: true,
      padding: 0.05, // Less padding for altitude
    },
    cadence: {
      color: "#4CAF50",
      label: "Cadence",
      visible: true,
      padding: 0.25,
    },
    heartrate: {
      color: colors.red,
      label: "Heart Rate",
      visible: true,
      padding: 0.1,
    },
    temp: {
      color: "#00BCD4",
      label: "Temperature",
      visible: true,
      padding: 0.15, // More padding for temperature
    },
    velocity: {
      color: "#2196F3",
      label: "Pace",
      visible: true,
      padding: 0.1,
    },
    watts: {
      color: "#FFC107",
      label: "Power",
      visible: true,
      padding: 0.1,
    },
  },

  // Add padding percentage for the y-scales
  yScalePadding: 0.1,

  smoothData(data, windowSize) {
    if (windowSize <= 1) return data;

    return data.map((point, i) => {
      const window = data.slice(
        Math.max(0, i - windowSize),
        Math.min(data.length, i + windowSize)
      );
      const smoothed = { ...point };
      Object.keys(this.metrics).forEach((metric) => {
        if (point[metric] != null) {
          smoothed[metric] = d3.mean(window, (d) => d[metric]);
        }
      });
      return smoothed;
    });
  },

  mounted() {
    this.imperial = JSON.parse(this.el.dataset["imperial"]);
    this.currentSmoothing = 20;

    const margin = { top: 20, right: 20, bottom: 30, left: 20 };
    const container = d3.select(this.el).style("position", "relative");

    const width = this.el.clientWidth;
    // Subtract 68px for the toggle controls at bottom
    const height = this.el.clientHeight - 68; // 68px for toggles

    // Create the svg element first
    const svg = container
      .append("svg")
      .attr("width", width)
      .attr("height", height)
      .attr("viewBox", [0, 0, width, height])
      .attr("style", "max-width: 100%; height: auto;")
      .attr("class", "text-gray-800 dark:text-white")
      .style("font-family", fonts.base);

    // Add controls after SVG
    const controls = container
      .append("div")
      .attr("class", "flex justify-between items-center p-2 h-[68px]");

    // Add container for toggles that we'll populate later
    this.toggles = controls.append("div").attr("class", "flex gap-2 flex-wrap");

    // Create tooltip
    const tooltip = container
      .append("div")
      .attr(
        "class",
        "absolute text-sm bg-white dark:bg-gray-700 shadow-md rounded px-2 py-1"
      )
      .style("opacity", 0)
      .style("pointer-events", "none");

    this.handleEvent("trackpoints", ({ trackpoints }) => {
      if (!trackpoints?.length) return;

      this.originalData = trackpoints;
      this.svg = svg;
      this.margin = margin;
      this.width = width;
      this.height = height;
      this.tooltip = tooltip;

      // Calculate which metrics are available and their averages
      const availableMetrics = {};
      const averages = {};

      Object.entries(this.metrics).forEach(([metric, config]) => {
        const values = trackpoints
          .map((d) => d[metric])
          .filter((v) => v != null);

        if (values.length > 0) {
          availableMetrics[metric] = config;
          let avg = d3.mean(values);
          if (metric === "velocity") {
            avg = formatVelocity(avg, this.imperial, "run");
          } else if (metric === "altitude") {
            avg = formatAltitude(avg, this.imperial);
          } else if (metric === "grade_smooth") {
            avg = `${Math.round(avg)}%`;
          } else if (metric === "temp") {
            avg = formatTemperature(avg, this.imperial);
          } else if (metric === "cadence") {
            avg = `${Math.round(avg * 2)}spm`;
          } else {
            avg = Math.round(avg);
          }
          averages[metric] = avg;
        }
      });

      // Update metrics object to only include available metrics
      this.metrics = availableMetrics;

      // Clear and rebuild toggles
      this.toggles.selectAll("*").remove();

      Object.entries(this.metrics).forEach(([metric, config]) => {
        const toggle = this.toggles
          .append("div")
          .attr("class", "flex items-center gap-2 cursor-pointer select-none")
          .on("click", (e) => {
            this.metrics[metric].visible = !this.metrics[metric].visible;
            e.target.closest("button").style.borderColor = this.metrics[metric]
              .visible
              ? this.metrics[metric].color
              : "transparent";
            this.updateChart();
          });

        const isVisible = this.metrics[metric].visible;

        toggle
          .append("button")
          .attr(
            "style",
            `border-color: ${
              isVisible ? this.metrics[metric].color : "transparent"
            };`
          )
          .attr(
            "class",
            "overflow-hidden rounded-lg bg-white dark:bg-gray-700 px-2 py-1 border-2"
          ).html(`
            <div class="truncate text-xs uppercase text-gray-500 dark:text-gray-200">${config.label}</div>
            <div class="mt-1 text-sm font-semibold tracking-tight text-gray-900 dark:text-white">${averages[metric]}</div>
          `);
      });

      this.updateChart();
    });
  },

  updateChart() {
    const { svg, margin, width, height, originalData } = this;

    // Clear existing elements
    svg.selectAll(".metric-line").remove();
    svg.selectAll(".axis").remove();
    svg.selectAll(".mouse-over-effects").remove();
    svg.selectAll("linearGradient").remove(); // Clear existing gradients

    // Apply smoothing
    const trackpoints = this.smoothData(originalData, this.currentSmoothing);

    // Create scales
    const x = d3
      .scaleLinear()
      .domain(d3.extent(trackpoints, (d) => d.time))
      .range([margin.left, width - margin.right]);

    const scales = {};
    Object.entries(this.metrics).forEach(([metric, config]) => {
      if (config.visible && trackpoints[0][metric] != null) {
        const extent = d3.extent(trackpoints, (d) => d[metric]);
        const padding = (extent[1] - extent[0]) * config.padding; // Use metric-specific padding
        scales[metric] = d3
          .scaleLinear()
          .domain([extent[0] - padding, extent[1] + padding])
          .range([height - margin.bottom, margin.top]);
      }
    });

    // Add X axis
    svg
      .append("g")
      .attr("class", "axis x-axis")
      .attr("transform", `translate(0,${height - margin.bottom})`)
      .call(d3.axisBottom(x).tickFormat((d) => formatDuration(d)));

    // Create line generator
    const line = d3
      .line()
      .x((d) => x(d.time))
      .curve(d3.curveMonotoneX);

    // Create area generator for gradient
    const area = d3
      .area()
      .x((d) => x(d.time))
      .y0(height - margin.bottom)
      .curve(d3.curveMonotoneX);

    // Add lines for visible metrics
    Object.entries(scales).forEach(([metric, scale]) => {
      const metricConfig = this.metrics[metric];

      if (metricConfig.gradient) {
        // Create gradient
        const gradientId = `gradient-${metric}`;
        const gradient = svg
          .append("defs")
          .append("linearGradient")
          .attr("id", gradientId)
          .attr("x1", "0%")
          .attr("y1", "0%")
          .attr("x2", "0%")
          .attr("y2", "100%");

        gradient
          .append("stop")
          .attr("offset", "0%")
          .attr("stop-color", metricConfig.color)
          .attr("stop-opacity", 0.4);

        gradient
          .append("stop")
          .attr("offset", "100%")
          .attr("stop-color", metricConfig.color)
          .attr("stop-opacity", 0);

        // Add area with gradient
        svg
          .append("path")
          .datum(trackpoints)
          .attr("class", "metric-line")
          .attr("fill", `url(#${gradientId})`)
          .attr(
            "d",
            area.y1((d) => scale(d[metric]))
          );
      }

      // Add the line
      svg
        .append("path")
        .datum(trackpoints)
        .attr("class", "metric-line")
        .attr("clip-path", "url(#clip)")
        .attr("fill", "none")
        .attr("stroke", metricConfig.color)
        .attr("stroke-width", 1.5)
        .attr(
          "d",
          line.y((d) => scale(d[metric]))
        );
    });

    // Add hover interaction
    this.addHoverEffects(trackpoints, x, scales);
  },

  zoomed(event) {
    const { svg } = this;

    // Update x-axis
    svg
      .select(".x-axis")
      .call(d3.axisBottom(event.transform.rescaleX(d3.scaleLinear())));

    // Update lines
    svg
      .selectAll(".metric-line")
      .attr(
        "transform",
        `translate(${event.transform.x},0) scale(${event.transform.k},1)`
      );
  },

  addHoverEffects(trackpoints, x, scales) {
    const { svg, margin, height, width, tooltip } = this;

    const mouseG = svg.append("g").attr("class", "mouse-over-effects");

    mouseG
      .append("path")
      .attr("class", "mouse-line")
      .style("stroke", isDarkMode() ? "white" : "black")
      .style("stroke-width", "1px")
      .style("opacity", "0");

    const overlay = mouseG
      .append("rect")
      .attr("width", width - margin.left - margin.right)
      .attr("height", height - margin.top - margin.bottom)
      .attr("transform", `translate(${margin.left},${margin.top})`)
      .attr("fill", "none")
      .attr("pointer-events", "all");

    overlay
      .on("mouseleave", () => {
        tooltip.style("opacity", 0);
        mouseG.select(".mouse-line").style("opacity", "0");
      })
      .on("mousemove", (event) => {
        const rect = svg.node().getBoundingClientRect();
        const mouseX = event.clientX - rect.left - margin.left;
        const x0 = x.invert(mouseX + margin.left);

        const bisect = d3.bisector((d) => d.time).left;
        const i = bisect(trackpoints, x0);

        if (i >= trackpoints.length) return;

        const d = trackpoints[i];

        mouseG
          .select(".mouse-line")
          .attr(
            "d",
            `M${x(d.time)},${margin.top} ${x(d.time)},${height - margin.bottom}`
          )
          .style("opacity", "1");

        // Format values based on metric type
        const tooltipContent = Object.entries(scales)
          .map(([metric, scale]) => {
            let value = d[metric];
            if (metric === "velocity") {
              value = formatVelocity(value, this.imperial, "run");
            } else if (metric === "altitude") {
              value = formatAltitude(value, this.imperial);
            } else if (metric === "grade_smooth") {
              value = `${Math.round(value)}%`;
            } else if (metric === "temp") {
              value = formatTemperature(value, this.imperial);
            } else if (metric === "cadence") {
              value = `${Math.round(value * 2)}spm`;
            } else {
              value = Math.round(value);
            }

            return `<div class="flex gap-2 items-center text-gray-800 dark:text-gray-200">
              <div style="background: ${this.metrics[metric].color}" class="rounded-full h-2 w-2"></div>
              <div>
                ${this.metrics[metric].label}: ${value}
              </div>
          </div>`;
          })
          .join("");

        // clear tooltip children
        tooltip.selectAll("*").remove();

        tooltip
          .append("div")
          .attr(
            "class",
            "text-gray-800 dark:text-gray-200 text-base font-semibold"
          )
          .text(formatDuration(d.time));
        tooltip
          .append("div")
          .attr(
            "class",
            "text-gray-800 dark:text-gray-400 text-sm font-semibold"
          )
          .text(formatDistance(d.distance, this.imperial));

        tooltip.append("div").html(tooltipContent);

        // tooltip.html(tooltipContent);

        // Get tooltip dimensions
        const tooltipWidth = tooltip.node().offsetWidth;
        const containerWidth = this.el.offsetWidth;

        // Calculate tooltip position
        const tooltipX = x(d.time);
        const tooltipY = event.clientY - rect.top;

        // Check if tooltip would overflow container on the right
        if (tooltipX + tooltipWidth + 10 > containerWidth) {
          // Position tooltip to the left of the cursor
          tooltip.style("left", `${tooltipX - tooltipWidth - 10}px`);
        } else {
          // Position tooltip to the right of the cursor
          tooltip.style("left", `${tooltipX + 10}px`);
        }

        tooltip.style("opacity", 1).style("top", `${tooltipY}px`);
      });
  },
};
