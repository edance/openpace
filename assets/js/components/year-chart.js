import Chart from 'chart.js';
import { u } from 'umbrellajs';
import { colors, fonts } from './../variables.js';

document.addEventListener("turbolinks:load", function() {
  const $chart = u('#chart-year');
  if ($chart.length === 0) {
    return;
  }

  const dataset = JSON.parse($chart.data('dataset'));

  new Chart($chart.first(), {
    type: 'line',
    options: {
      responsive: true,
      maintainAspectRatio: false,
      layout: {
        padding: 0
      },
      legend: {
        display: false,
      },
      elements: {
        point: {
          radius: 5,
          backgroundColor: colors.theme['primary']
        },
        line: {
          tension: .4,
          borderWidth: 4,
          borderColor: colors.theme['primary'],
          backgroundColor: colors.transparent,
          borderCapStyle: 'rounded'
        },
      },
      tooltips: {
        callbacks: {
          label: function(tooltipItem) {
            return dataset[tooltipItem.index].formatted_distance;
          },
        },
        displayColors: false,
      },
    },
    data: {
      labels: dataset.map(x => x.label),
      datasets: [{
        data: dataset.map(x => x.distance),
      }]
    }
  });
});
