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

function weeklyDistanceTotalByType(type, activities) {
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
        obj[dateStr] = obj[dateStr] + activity.distance / 1609;
      }

      return obj;
    }, dates);

  return Object.keys(dateMap).sort().map(key => dateMap[key]);
}

function init() {
  const el = document.getElementById('recent-activities-chart');

  if (!el) {
    return;
  }

  const activities = JSON.parse(el.dataset['summaries']);
  const imperial = JSON.parse(el.dataset['imperial']);
  const types = activities.map(x => x.type).filter((v, i, a) => a.indexOf(v) === i);

  const datasets = types.map(type => {
    return {
      label: type,
      backgroundColor: hexToRGB(activityColor(type), 0.2),
      borderColor: hexToRGB(activityColor(type), 1.0),
      borderWidth: 1,
      data: weeklyDistanceTotalByType(type, activities),
    };
  });

  const data = {
    datasets,
    labels: lastXWeeks().map(x => x.toLocaleString({ month: 'short', day: 'numeric' })),
  };

  const ctx = el.getContext('2d');
  const myChart = new Chart(ctx, {
    type: 'bar',
    data,
    options: {
      aspectRatio: 4 / 2,
      layout: {
        // padding: 30,
      },
      plugins: {
        // tooltip: {
        //   callbacks: {
        //     label: function(context) {
        //       const value = context.dataset.data[context.dataIndex];
        //       const label = imperial ? 'mi' : 'km';

        //       return value.activities.map(x => {
        //         return `${x.type} - ${calcDistance(x.distance, imperial, 1)}${label}`;
        //       }).join('\n');
        //     },
        //   },
        // },
        legend: {
          position: 'bottom',
          labels: {
            boxWidth: 20,
            boxHeight: 20,
            pointStyle: 'circle',
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
    },
  });
}

window.addEventListener("phx:page-loading-stop", init);
