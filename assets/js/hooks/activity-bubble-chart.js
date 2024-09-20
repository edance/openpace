import { Chart, LinearScale, PointElement, Tooltip } from "chart.js";
import { BubbleController } from "chart.js";
import { DateTime } from "luxon";
import { colors } from "../variables";
import {
  hexToRGB,
  velocityToPace,
  formatVelocity,
  paceToVelocity,
} from "../utils";

// TODO: Add padding
// TODO: Link to activity

Chart.register(LinearScale, PointElement, Tooltip, BubbleController);

const workoutTypeColors = {
  default: hexToRGB(colors.blue, 0.6),
  long_run: hexToRGB(colors.green, 0.6),
  workout: hexToRGB(colors.yellow, 0.6),
  race: hexToRGB(colors.red, 0.6),
};

const getOrCreateTooltip = (chart) => {
  let tooltipEl = chart.canvas.parentNode.querySelector("div");

  if (!tooltipEl) {
    const classList =
      "absolute w-40 text-sm bg-white shadow-md rounded px-2 py-1".split(" ");

    tooltipEl = document.createElement("div");
    tooltipEl.classList.add(...classList);
    tooltipEl.style.opacity = 1;
    tooltipEl.style.pointerEvents = "none";
    tooltipEl.style.transform = "translate(-50%, 0)";
    tooltipEl.style.transition = "all .1s ease";

    const tooltipHeader = document.createElement("div");
    tooltipHeader.classList.add(...["font-bold"]);
    const tooltipBody = document.createElement("div");

    tooltipEl.appendChild(tooltipHeader);
    tooltipEl.appendChild(tooltipBody);
    chart.canvas.parentNode.appendChild(tooltipEl);
  }

  return tooltipEl;
};

const externalTooltipHandler = (context, imperial) => {
  // Tooltip Element
  const { chart, tooltip } = context;
  const tooltipEl = getOrCreateTooltip(chart);

  // Hide if no tooltip
  if (tooltip.opacity === 0) {
    tooltipEl.style.opacity = 0;
    return;
  }

  const dataPoint = tooltip.dataPoints[0];

  // Set Text
  if (dataPoint) {
    // const bodyLines = tooltip.body.map((b) => b.lines);
    const [tooltipHeader, tooltipBody] = tooltipEl.querySelectorAll("div");
    const dataIndex = dataPoint.dataIndex;
    const datasetIndex = dataPoint.datasetIndex;
    const data = chart.data.datasets[datasetIndex].data[dataIndex];

    tooltipHeader.innerHTML = data.name;

    const tooltipFeatures = [
      `${data.x} ${imperial ? "mi" : "km"}`,
      formatVelocity(data.y, imperial, "run"),
      // formatDuration(data.elapsed_time),
    ];
    tooltipBody.innerHTML = tooltipFeatures.join(" &middot; ");
  }

  const { offsetLeft: positionX, offsetTop: positionY } = chart.canvas;

  // Display, position, and set styles for font
  const topPadding = 20;
  tooltipEl.style.opacity = 1;
  tooltipEl.style.left = positionX + tooltip.caretX + "px";
  tooltipEl.style.top = positionY + tooltip.caretY + topPadding + "px";
  tooltipEl.style.font = tooltip.options.bodyFont.string;
  tooltipEl.style.padding =
    tooltip.options.padding + "px " + tooltip.options.padding + "px";
};

export default {
  mounted() {
    const isDarkMode = document.documentElement.classList.contains("dark");
    this.imperial = JSON.parse(this.el.dataset["imperial"]);
    const ctx = this.el.getContext("2d");
    this.chart = new Chart(ctx, {
      type: "scatter",
      data: {
        datasets: [
          {
            label: "Default",
            data: [],
            backgroundColor: workoutTypeColors.default,
            pointHoverRadius: 10,
          },
          {
            label: "Long Run",
            data: [],
            backgroundColor: workoutTypeColors.long_run,
            pointHoverRadius: 10,
          },
          {
            label: "Workout",
            data: [],
            backgroundColor: workoutTypeColors.workout,
            pointHoverRadius: 10,
          },
          {
            label: "Race",
            data: [],
            backgroundColor: workoutTypeColors.race,
            pointHoverRadius: 10,
          },
        ],
      },
      options: {
        scales: {
          x: {
            type: "linear",
            position: "bottom",
            title: {
              display: true,
              color: isDarkMode ? "white" : colors.black,
              text: "Distance",
            },
            ticks: {
              color: isDarkMode ? "white" : colors.black,
            },
          },
          y: {
            type: "linear",
            grid: {
              display: false,
            },
            min: 0,
            max: 20,
            ticks: {
              stepSize: 0.5,
              color: isDarkMode ? "white" : colors.black,
              callback: (value) => {
                return formatVelocity(value, this.imperial, "run");
              },
            },
            title: {
              display: true,
              color: isDarkMode ? "white" : colors.black,
              text: "Pace",
            },
          },
        },
        onHover: (event, elements) => {
          event.native.target.style.cursor = elements.length
            ? "pointer"
            : "default";
        },
        onClick: (_event, elements, chart) => {
          if (elements.length > 0) {
            const clickedElement = elements[0];
            const datasetIndex = clickedElement.datasetIndex;
            const index = clickedElement.index;
            const clickedData = chart.data.datasets[datasetIndex].data[index];

            this.pushEvent("open-activity", { slug: clickedData.slug });
          }
        },
        plugins: {
          legend: {
            labels: {
              usePointStyle: true,
              color: isDarkMode ? "white" : colors.black,
              pointStyle: "circle",
              boxWidth: 4,
              boxHeight: 4,
            },
          },

          tooltip: {
            enabled: false,
            external: (ctx) => externalTooltipHandler(ctx, this.imperial),
          },
        },
      },
    });

    this.handleEvent("update-year", ({ year }) => {
      this.year = year;

      this.updateChart();
    });

    this.handleEvent("summaries", ({ summaries }) => {
      this.data = summaries;
      this.updateChart();
    });
  },

  updateChart() {
    if (!this.chart || !this.data) {
      return;
    }

    const filteredData = this.year
      ? this.data.filter(
          (d) =>
            DateTime.fromISO(d.start_at_local).year === parseInt(this.year, 10)
        )
      : this.data;

    const chartData = filteredData
      .filter((d) => d.activity_type === "run")
      .map((activity) => ({
        ...activity,
        y: activity.velocity,
        x: activity.distance,
        workout_type: activity.workout_type || "default",
      }));

    // get the max velocity from the data
    const maxVelocity = Math.max(...chartData.map((d) => d.y)) + 0.5;
    const minVelocity = Math.min(...chartData.map((d) => d.y)) + 0.5;

    const maxPace = Math.floor(velocityToPace(maxVelocity, this.imperial));
    const minPace = Math.ceil(velocityToPace(minVelocity, this.imperial));

    this.chart.options.scales.y.max = paceToVelocity(maxPace, this.imperial);
    this.chart.options.scales.y.min = paceToVelocity(minPace, this.imperial);

    // group by workout type
    const groupedData = chartData.reduce((acc, d) => {
      if (!acc[d.workout_type]) {
        acc[d.workout_type] = [];
      }

      acc[d.workout_type].push(d);
      return acc;
    }, {});

    this.chart.data.datasets.forEach((dataset) => {
      dataset.data =
        groupedData[dataset.label.toLowerCase().replace(" ", "_")] || [];
    });

    // this.chart.data.datasets[0].data = chartData;
    this.chart.update();
  },
};
