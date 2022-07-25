import Chart from 'chart.js/auto';
import ChartDataLabels from 'chartjs-plugin-datalabels';
import { parse } from 'date-fns';
import { colors, fonts } from './../variables.js';
import { calcDistance, calcFeet, roundTo } from '../utils';

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

function bubbleSize(activities) {
  const minBubble = 10;
  const maxBubble = 25;
  const distance = activities.map(x => x.distance).reduce((a, b) => a + b, 0) / 1609;
  if (distance === 0) {
    return 0;
  }

  return Math.min(distance, 20) / 20.0 * (maxBubble - minBubble) + minBubble;
}

export default {
  mounted() {
    const dataset = JSON.parse(this.el.dataset['summaries']);
    const imperial = JSON.parse(this.el.dataset['imperial']);
    const data = dataset.map((val, idx) => {
      const types = val.activities.map(x => x.type).filter((v, i, a) => a.indexOf(v) === i);

      return {
        date: parse(val.date, 'yyyy-MM-dd', new Date()),
        activities: val.activities,
        x: idx % 7,
        y: Math.floor(idx / 7) * -1,
        r: bubbleSize(val.activities),
        types: types
      };
    });

    const ctx = this.el.getContext('2d');
    this.chart = new Chart(ctx, {
      plugins: [ChartDataLabels],
      type: 'bubble',
      data: {
        datasets: [{
          data: data,
          backgroundColor: function(context) {
            const index = context.dataIndex;
            const value = context.dataset.data[index];

            if (value.types.length === 1) {
              const type = value.types[0];
              if (type === 'Run') { return backgroundColors[0]; }
              if (type === 'Ride') { return backgroundColors[1]; }
            }
            return backgroundColors[2];
          },
          borderColor: function(context, options) {
            const index = context.dataIndex;
            const value = context.dataset.data[index];

            if (value.types.length === 1) {
              const type = value.types[0];
              if (type === 'Run') { return borderColor[0]; }
              if (type === 'Ride') { return borderColor[1]; }
            }
            return backgroundColors[2];
          },
          borderWidth: 1
        }]
      },
      options: {
        aspectRatio: 4 / 3,
        layout: {
          padding: 30,
        },
        plugins: {
          tooltip: {
            callbacks: {
              label: function(context) {
                const value = context.dataset.data[context.dataIndex];
                const label = imperial ? 'mi' : 'km';

                return value.activities.map(x => {
                  return `${x.type} - ${calcDistance(x.distance, imperial, 1)}${label}`;
                }).join('\n');
              },
            },
          },
          legend: {
            display: false,
          },
          datalabels: {
            anchor: function(context) {
              var value = context.dataset.data[context.dataIndex];
              return 'center';
            },
            align: function(context) {
              var value = context.dataset.data[context.dataIndex];
              return 'center';
            },
            color: function(context) {
              var value = context.dataset.data[context.dataIndex];
              return 'white';
            },
            font: {
              weight: 'bold'
            },
            formatter: function(value) {
              const { date } = value;
              return date.getDate();
            },
            offset: 2,
            padding: 0
          },
        },
        scales: {
          x: {
            display: false,
            grid: {
              display: false,
            }
          },
          y: {
            display: false,
            grid: {
              display: false,
            }
          }
        },
      },
    });
  }
}

