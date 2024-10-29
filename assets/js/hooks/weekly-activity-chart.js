import Chart from "chart.js/auto";
import { formatDistance, isDarkMode } from "../utils";
import { colors } from "../variables";

export default {
  mounted() {
    this.imperial = JSON.parse(this.el.dataset["imperial"]);
    this.isDark = isDarkMode();

    this.handleEvent("recent_activities", (data) => {
      this.activities = data.activities;
      this.loadChart();
    });
  },

  processWeeklyData() {
    const sortedActivities = [...this.activities].sort(
      (a, b) => new Date(a.start_at_local) - new Date(b.start_at_local)
    );

    const weeklyData = new Map();

    sortedActivities.forEach((activity) => {
      const date = new Date(activity.start_at_local);
      const daysToMonday = date.getDay() === 0 ? 6 : date.getDay() - 1;
      const weekStart = new Date(date.setDate(date.getDate() - daysToMonday));
      weekStart.setHours(0, 0, 0, 0);

      const weekKey = weekStart.toISOString().split("T")[0];
      const currentDistance = weeklyData.get(weekKey) || 0;
      weeklyData.set(weekKey, currentDistance + activity.distance);
    });

    const weeks = Array.from(weeklyData.entries())
      .slice(-18)
      .map(([date, distance]) => ({
        date,
        distance: this.imperial ? distance / 1609.34 : distance / 1000,
      }));

    return weeks;
  },

  formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString("en-US", { month: "short", day: "numeric" });
  },

  loadChart() {
    const weeklyData = this.processWeeklyData();
    const unit = this.imperial ? "mi" : "km";

    const data = {
      labels: weeklyData.map((week) => this.formatDate(week.date)),
      datasets: [
        {
          label: "Weekly Distance",
          data: weeklyData.map((week) => week.distance),
          borderColor: "#6366f1", // indigo-500
          backgroundColor: "rgba(99, 102, 241, 0.1)",
          fill: true,
          tension: 0.3,
        },
      ],
    };

    this.chart = new Chart(this.el.getContext("2d"), {
      type: "line",
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
          tooltip: {
            backgroundColor: this.isDark ? colors.black : colors.white,
            titleColor: this.isDark ? colors.white : colors.black,
            bodyColor: this.isDark ? colors.white : colors.black,
            callbacks: {
              label: (context) => {
                return `Distance: ${formatDistance(
                  context.raw * (this.imperial ? 1609.34 : 1000),
                  this.imperial,
                  2
                )}`;
              },
            },
          },
        },
        scales: {
          y: {
            beginAtZero: true,
            grid: {
              display: true,
              drawBorder: false,
              color: this.isDark ? "rgba(255, 255, 255, 0.1)" : "rgba(0, 0, 0, 0.1)",
            },
            ticks: {
              color: this.isDark ? colors.white : colors.black,
              callback: (value) => `${value}${unit}`,
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
