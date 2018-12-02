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
          radius: 0,
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
    },
    data: {
      labels: dataset.map(x => x.date),
      datasets: [{
        data: dataset.map(x => x.sum / 1609),
      }]
    }
  });
});
