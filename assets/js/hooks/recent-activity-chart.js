import Chart from 'chart.js/auto';
import { colors, fonts } from './../variables.js';
import { activityColor, calcDistance, calcFeet, formatNumber, hexToRGB, roundTo } from '../utils';
import { DateTime, Duration } from "luxon";

function lastXWeeks() {
  const weekCount = 20;
  const now = DateTime.now();
  const startDate = now.startOf("week").minus({ weeks: weekCount - 1 });
  const dates = [];

  for (let i = 0; i < weekCount; i++) {
    dates.push(startDate.plus({ weeks: i }));
  }

  return dates;
}

// Return only activity types that have a distance of gt 0
function eligibleTypes(field, activities) {
  const sumByType = activities.reduce((obj, a) => {
    obj[a.activity_type] = (obj[a.activity_type] || 0) + a[field];
    return obj;
  }, {});
  return Object.keys(sumByType).filter((x) => sumByType[x] > 0);
}

export default {
  weeklyAmountTotalByType(type) {
    const dates = this.weeks.reduce((obj, week) => {
      obj[week.toISODate()] = 0;
      return obj;
    }, {});

    const dateMap = this.activities
          .filter(x => x.activity_type === type)
          .reduce((obj, activity) => {
            const date = DateTime.fromISO(activity.start_at_local).startOf("week");
            const dateStr = date.toISODate();

            if (Object.keys(obj).includes(dateStr)) {
              obj[dateStr] = obj[dateStr] + activity[this.field];
            }

            return obj;
          }, dates);

    return Object.keys(dateMap).sort().map(key => {
      if (this.field === 'distance') {
        return calcDistance(dateMap[key], this.imperial, 1);
      }
      if (this.field === 'elevation_gain') {
        return calcFeet(dateMap[key], this.imperial, 0);
      }

      return dateMap[key];
    });
  },
  calcChartData() {
    const types = eligibleTypes(this.field, this.activities);
    const datasets = types.map(type => {
      return {
        label: type,
        backgroundColor: (context) => {
          const week = this.weeks[context.dataIndex];
          if (this.currentDate.hasSame(week, 'week')) {
            return hexToRGB(activityColor(type), 0.8);
          }
          return hexToRGB(activityColor(type), 0.2);
        },
        borderColor: hexToRGB(activityColor(type), 1.0),
        borderWidth: 1,
        data: this.weeklyAmountTotalByType(type, this.field, this.activities),
      };
    });

    return {
      datasets,
      labels: this.weeks.map(x => x.toLocaleString({ month: 'short', day: 'numeric' })),
    };
  },

  mounted() {
    this.activities = JSON.parse(this.el.dataset['summaries']);
    this.imperial = JSON.parse(this.el.dataset['imperial']);
    this.currentDate = DateTime.fromISO(this.el.dataset['currentDate']);
    this.weeks = lastXWeeks();
    this.field = 'distance';

    const hook = this;
    const ctx = this.el.getContext('2d');
    this.chart = new Chart(ctx, {
      type: 'bar',
      data: this.calcChartData(),
      options: {
        maintainAspectRatio: false,
        elements: {
          pointStyle: 'circle',
        },
        plugins: {
          tooltip: {
            callbacks: {
              title: (context) => {
                if (context.length !== 1) {
                  return null;
                }

                return `Week of ${context[0].label}`;
              },
              label: (context) => {
                if (this.field === 'distance') {
                  const label = this.imperial ? 'mi' : 'km';
                  return `${context.dataset.label}: ${context.formattedValue} ${label}`;
                }
                if (this.field === 'elevation_gain') {
                  const label = this.imperial ? 'ft' : 'm';
                  return `${context.dataset.label}: ${context.formattedValue} ${label}`;
                }

                const value = context.dataset.data[context.dataIndex];
                const duration = Duration.fromObject({ seconds: value });
                return `${context.dataset.label}: ${duration.toFormat("h 'hr' mm 'min'")}`;
              },
            },
          },
          legend: {
            position: 'bottom',
            labels: {
              boxWidth: 6,
              usePointStyle: true,
              color: 'white',
              padding: 15,
            },
          },
        },
        scales: {
          x: {
            stacked: true,
            grid: {
              display: false,
            },
            ticks: {
              color: 'white',
            },
          },
          y: {
            stacked: true,
            grid: {
              display: false,
            },
            ticks: {
              color: 'white',
              callback: (value, index, ticks) => {
                if (this.field === 'distance') {
                  const label = this.imperial ? 'mi' : 'km';
                  return formatNumber(value) + label;
                }
                if (this.field === 'elevation_gain') {
                  const label = this.imperial ? 'ft' : 'm';
                  return formatNumber(value) + label;
                }

                const duration = Duration.fromObject({ seconds: value });
                return duration.toFormat("h'hr'");
              },
            },
          },
        },
        onHover: (evt) => {
          const { chart } = evt;
          const points = chart.getElementsAtEventForMode(evt, 'nearest', { intersect: true }, true);

          if (points.length) {
            evt.native.target.style.cursor = 'pointer';
          }
          else {
            evt.native.target.style.cursor = 'inherit';
          }
        },
        onClick: (evt) => {
          const { chart } = evt;
          const points = chart.getElementsAtEventForMode(evt, 'nearest', { intersect: true }, true);

          if (points.length) {
            const firstPoint = points[0];
            const date = this.weeks[firstPoint.index];
            // Send event to backend
            hook.pushEvent("load-week", { date: date.toISODate() });
            this.currentDate = date;

            this.chart.update();
          }
        }
      },
    });

    $('#recent-activities-chart-type').on('change', (evt) => {
      this.field = evt.currentTarget.value;
      this.chart.data = this.calcChartData();
      this.chart.options.scales.y.ticks['stepSize'] = this.field === 'duration' ? 3600 : null;

      this.chart.update();
    });
  }
}
