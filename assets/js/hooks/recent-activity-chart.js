import Chart from 'chart.js/auto';
import { parse } from 'date-fns';
import { colors, fonts } from './../variables.js';
import { calcDistance, calcFeet, hexToRGB, roundTo } from '../utils';
import { DateTime } from "luxon";

const backgroundColors = [
  'rgba(255, 99, 132, 0.2)',
  'rgba(54, 162, 235, 0.2)',
  'rgba(255, 206, 86, 0.2)',
  'rgba(75, 192, 192, 0.2)',
  'rgba(153, 102, 255, 0.2)',
  'rgba(255, 159, 64, 0.2)'
];
const borderColor = [
  'rgba(255, 99, 132, 1)',
  'rgba(54, 162, 235, 1)',
  'rgba(255, 206, 86, 1)',
  'rgba(75, 192, 192, 1)',
  'rgba(153, 102, 255, 1)',
  'rgba(255, 159, 64, 1)'
];

function activityColor(type) {
  const map = {
    'Run': colors['red'],
    'Hike': colors['orange'],
    'Ride': colors['blue'],
    'Swim': colors['green'],
  };

  return map[type] || colors['yellow'];
}

function lastXWeeks() {
  const weekCount = 52;
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
    obj[a.type] = (obj[a.type] || 0) + a[field];
    return obj;
  }, {});
  return Object.keys(sumByType).filter((x) => sumByType[x] > 0);
}

function weeklyAmountTotalByType(type, field, activities) {
  const weeks = lastXWeeks();
  const dates = weeks.reduce((obj, week) => {
    obj[week.toISODate()] = 0;
    return obj;
  }, {});

  const dateMap = activities
    .filter(x => x.type === type)
    .reduce(function(obj, activity){
      const date = DateTime.fromISO(activity.start_at_local).startOf("week");
      const dateStr = date.toISODate();
      if (Object.keys(obj).includes(dateStr)) {
        obj[dateStr] = obj[dateStr] + activity[field] / 1609;
      }

      return obj;
    }, dates);

  return Object.keys(dateMap).sort().map(key => dateMap[key]);
}


export default {
  mounted() {
    const activities = JSON.parse(this.el.dataset['summaries']);
    const imperial = JSON.parse(this.el.dataset['imperial']);
    const weeks = lastXWeeks();
    const field = 'distance';
    const types = eligibleTypes(field, activities);

    const datasets = types.map(type => {
      return {
        label: type,
        backgroundColor: hexToRGB(activityColor(type), 0.2),
        borderColor: hexToRGB(activityColor(type), 1.0),
        borderWidth: 1,
        data: weeklyAmountTotalByType(type, field, activities),
      };
    });

    const data = {
      datasets,
      labels: weeks.map(x => x.toLocaleString({ month: 'short', day: 'numeric' })),
    };

    const hook = this;
    const ctx = this.el.getContext('2d');
    this.chart = new Chart(ctx, {
      type: 'bar',
      data,
      options: {
        aspectRatio: 4 / 2,
        elements: {
          pointStyle: 'circle',
        },
        plugins: {
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
            },
          },
        },
        onClick: (evt) => {
          const { chart } = evt;
          const points = chart.getElementsAtEventForMode(evt, 'nearest', { intersect: true }, true);

          if (points.length) {
            const firstPoint = points[0];
            const date = weeks[firstPoint.index];
            // Send event to backend
            hook.pushEvent("load-week", { date: date.toISODate() });
          }
        }
      },
    });
  }
}
