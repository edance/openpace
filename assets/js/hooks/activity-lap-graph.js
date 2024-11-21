import * as d3 from "d3";
import {
  calcDistance,
  range,
  pad,
  roundTo,
  isDarkMode,
  formatDistance,
  formatVelocity,
  formatDuration,
} from "../utils";
import { colors, fonts } from "./../variables.js";

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

    container.attr("style", "position: relative;");

    // Create the svg and append it to the container
    const svg = container
      .append("svg")
      .attr("width", width)
      .attr("height", height)
      .attr("viewBox", [0, 0, width, height])
      .attr("style", "max-width: 100%; height: auto; height: intrinsic;")
      .attr("class", "text-gray-800 dark:text-white")
      .style("font-family", fonts.base);

    // Create a div for the tooltip and hide it initially
    const tooltip = container
      .append("div")
      .attr(
        "class",
        "absolute text-sm bg-white dark:bg-gray-700 shadow-md rounded px-2 py-1"
      )
      .style("opacity", 0)
      .style("top", "0")
      .style("pointer-events", "none");

    const tooltipHeader = tooltip
      .append("div")
      .attr(
        "class",
        "text-gray-800 dark:text-gray-200 text-base font-semibold"
      );
    const tooltipBody = tooltip
      .append("div")
      .attr("class", "text-gray-800 dark:text-gray-200 text-sm");

    this.handleEvent("laps", ({ laps, training_paces }) => {
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
      const yPadding = (maxPace - minPace) / 4;

      const x = d3
        .scaleLinear()
        .domain([0, totalDistance])
        .range([margin.left, width - margin.right]);

      const y = d3
        .scaleLinear()
        .domain([minPace - yPadding, maxPace + yPadding])
        .range([margin.top, height - margin.bottom]);

      const xAxis = (g) =>
        g
          .call(d3.axisBottom(x))
          .call((g) =>
            g
              .select(".domain")
              .attr("class", "stroke-gray-800 dark:stroke-white")
          )
          .call((g) =>
            g
              .selectAll(".tick line")
              .attr("class", "stroke-gray-800 dark:stroke-white")
          )
          .call((g) =>
            g
              .selectAll(".tick text")
              .attr("class", "fill-gray-800 dark:fill-white")
          );

      const yAxis = (g) =>
        g
          .call(
            d3
              .axisLeft(y)
              .tickValues(range(minPace, maxPace))
              .tickFormat((d) => this.yTick(d))
          )
          .call((g) =>
            g
              .select(".domain")
              .attr("class", "stroke-gray-800 dark:stroke-white")
          )
          .call((g) =>
            g
              .selectAll(".tick line")
              .attr("class", "stroke-gray-800 dark:stroke-white")
          )
          .call((g) =>
            g
              .selectAll(".tick text")
              .attr("class", "fill-gray-800 dark:fill-white")
          );

      // Update the axis appending
      svg
        .append("g")
        .attr("transform", `translate(0, ${height - margin.bottom})`)
        .attr("class", "axis")
        .call(xAxis);

      svg
        .append("g")
        .attr("transform", `translate(${margin.left}, 0)`)
        .attr("class", "axis")
        .call(yAxis);

      const mouseLine = svg
        .append("path") // create vertical line to follow mouse
        .attr("class", "mouse-line")
        .attr("stroke", isDarkMode() ? "white" : colors.black)
        .attr("stroke-width", 1)
        .attr("opacity", 0);

      // Create gradient definitions for each training pace
      const defs = svg.append("defs");

      // Helper function to create gradient for a pace
      const createGradient = (id, color) => {
        const gradient = defs
          .append("linearGradient")
          .attr("id", id)
          .attr("x1", "0%")
          .attr("y1", "0%")
          .attr("x2", "0%")
          .attr("y2", "100%");

        gradient
          .append("stop")
          .attr("offset", "0%")
          .attr("stop-color", color)
          .attr("stop-opacity", 1);

        gradient
          .append("stop")
          .attr("offset", "100%")
          .attr("stop-color", color)
          .attr("stop-opacity", 0.2);

        return `url(#${id})`;
      };

      console.log("training", training_paces);

      // Helper function to get gradient for a pace
      const getTrainingPaceGradient = (speed) => {
        if (!training_paces) {
          return createGradient("default-gradient", "rgb(99 102 241)");
        }

        const matchingPace = training_paces.find(
          (pace) => speed >= pace.min_speed && speed <= pace.max_speed
        );

        const color = matchingPace ? matchingPace.color : "rgb(99 102 241)";
        const id = `gradient-${
          matchingPace ? matchingPace.name.toLowerCase() : "default"
        }`;

        return createGradient(id, color);
      };

      // Create the lap bars
      const bars = svg
        .append("g")
        .selectAll("rect")
        .data(laps)
        .join("rect")
        .on("mouseover", function (evt) {
          evt.target.style.cursor = "pointer";
          d3.select(this).transition().attr("fill-opacity", 1);
          mouseLine.transition().attr("opacity", 1);
          tooltip.transition().style("opacity", 1);
        })
        .on("mouseout", function (evt) {
          d3.select(this).transition().attr("fill-opacity", 0.5);
          evt.target.style.cursor = "inherit";
          mouseLine.transition().attr("opacity", 0);
          tooltip.transition().style("opacity", 0);
        })
        .on("mousemove", (evt) => {
          // get d3 object from event
          const elem = d3.select(evt.target);

          const barX = parseFloat(elem.attr("x"));
          const barWidth = parseFloat(elem.attr("width"));
          const barY = parseFloat(elem.attr("y"));
          let posX = Math.round(barX + barWidth / 2);

          mouseLine.attr("d", `M ${posX} 0 V ${barY}`);
          const data = elem.data()[0];

          // Find matching training pace
          const matchingPace = training_paces?.find(
            (pace) =>
              data.average_speed >= pace.min_speed &&
              data.average_speed <= pace.max_speed
          );

          tooltipHeader.html(`Lap ${data.split}`);

          const tooltipFeatures = [
            matchingPace?.name,
            formatDistance(data.distance, this.imperial, 2),
            formatVelocity(
              data.average_speed,
              this.imperial,
              this.activityType
            ),
            formatDuration(data.elapsed_time),
          ].filter((x) => x);

          // Add color dot for the zone
          const colorDot = matchingPace
            ? `<div class="flex gap-2 items-center">
         <div style="background: ${
           matchingPace.color
         }" class="rounded-full h-2 w-2"></div>
         <div>${tooltipFeatures.join(" &middot; ")}</div>
       </div>`
            : tooltipFeatures.join(" &middot; ");

          tooltipBody.html(colorDot);

          const tooltipWidth = tooltip.node().getBoundingClientRect().width;
          posX = posX - tooltipWidth / 2;

          const svgWidth = svg.node().getBoundingClientRect().width;
          if (posX + tooltipWidth > svgWidth) {
            tooltip.style("left", "auto").style("right", "0");
          } else {
            tooltip.style("left", posX + "px").style("right", "auto");
          }
        })
        .attr("fill", (d) => getTrainingPaceGradient(d.average_speed))
        .attr("fill-opacity", 0.5)
        .attr("stroke", (d) => {
          const matchingPace = training_paces?.find(
            (pace) =>
              d.average_speed >= pace.min_speed &&
              d.average_speed <= pace.max_speed
          );
          return matchingPace ? matchingPace.color : "rgb(99 102 241)";
        })
        .attr("stroke-width", 2)
        .attr("stroke-opacity", 1.0)
        .attr("rx", 8) // rounded corners
        .attr("ry", 8) // rounded corners
        .attr("x", (_, idx) => {
          let values = [0, ...xValues];
          values = values.map((_, index) =>
            values.slice(0, index + 1).reduce((a, b) => a + b)
          );
          return x(values[idx]) + 1;
        })
        .attr("y", () => y(maxPace + yPadding))
        .attr("height", 0)
        .attr("width", (_, i) => x(xValues[i]) - x(0) - 2);

      // Animate the bars for fun
      bars
        .transition()
        .ease(d3.easeLinear)
        .duration(800)
        .attr("y", (_, i) => y(yValues[i]))
        .attr("height", (_, i) => y(maxPace + yPadding) - y(yValues[i]))
        .delay((_, i) => i * 100);
    });
  },
};
