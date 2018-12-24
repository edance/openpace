import Chart from 'chart.js';
import { u } from 'umbrellajs';
import { colors, fonts } from './../variables.js';

document.addEventListener("turbolinks:load", function() {
  const $chart = u('#chart-week');
  if ($chart.length === 0) {
    return;
  }

  const dataset = JSON.parse($chart.data('dataset'));

  new Chart($chart.first(), {
    type: 'bar',
    options: {
      responsive: true,
      maintainAspectRatio: false,
      layout: {
        padding: 0
      },
      legend: {
        display: false,
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
      labels: ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
      datasets: [{
        backgroundColor: colors.theme['warning'],
        data: dataset.map(x => x.distance),
      }],
    }
  });
});
