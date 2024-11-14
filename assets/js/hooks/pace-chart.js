import Chart from "chart.js/auto";
import { formatDistance, isDarkMode } from "../utils";
import { colors } from "../variables";

export default {
  mounted() {
    this.imperial = JSON.parse(this.el.dataset["imperial"]);
    this.isDark = isDarkMode();
    this.field = "total_duration";

    this.handleEvent("pace_bands", (data) => {
      this.paceBands = data.pace_bands;
      this.loadChart();
    });
  },

  formatTime(minutes) {
    const hours = Math.floor(minutes / 60);
    const mins = Math.floor(minutes % 60);
    const secs = Math.round((minutes - Math.floor(minutes)) * 60);

    if (hours > 0) {
      return `${hours}h ${mins.toString().padStart(2, "0")}m`;
    }
    return `${mins}m ${secs.toString().padStart(2, "0")}s`;
  },

  loadChart() {
    const data = {
      labels: this.paceBands.map((x) => x.pace_name),
      datasets: [
        {
          label: "Time Spent",
          data: this.paceBands.map((x) => x[this.field] / 60),
          backgroundColor: this.paceBands.map((x) => x.pace_color),
          borderColor: this.paceBands.map((x) => x.pace_color),
          borderWidth: 1,
          borderRadius: {
            topLeft: 10,
            topRight: 10,
            bottomLeft: 0,
            bottomRight: 0,
          },
          borderSkipped: false,
        },
      ],
    };

    this.chart = new Chart(this.el.getContext("2d"), {
      type: "bar",
      data: data,
      options: {
        responsive: true,
        layout: {
          padding: {
            top: 20,
            right: 20,
            bottom: 20,
            left: 20,
          },
        },
        plugins: {
          legend: {
            display: false,
          },
          title: {
            display: false,
          },
          tooltip: {
            backgroundColor: this.isDark ? colors.black : colors.white,
            titleColor: this.isDark ? colors.white : colors.black,
            bodyColor: this.isDark ? colors.white : colors.black,
            callbacks: {
              label: (context) => {
                const band = this.paceBands[context.dataIndex];
                return [
                  `Time: ${this.formatTime(context.raw)}`,
                  `Distance: ${formatDistance(
                    band.total_distance,
                    this.imperial,
                    2
                  )}`,
                  `Activities: ${band.activity_count}`,
                ];
              },
            },
          },
        },
        scales: {
          y: {
            beginAtZero: true,
            grid: {
              display: false,
            },
            ticks: {
              color: this.isDark ? colors.white : colors.black,
              callback: (value) => this.formatTime(value),
            },
          },
          x: {
            grid: {
              display: false,
            },
            ticks: {
              color: this.isDark ? colors.white : colors.black,
            },
          },
        },
      },
    });
  },
};

