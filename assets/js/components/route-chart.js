import Chart from 'chart.js';
import { u } from 'umbrellajs';
import { colors, fonts } from './../variables.js';

document.addEventListener("turbolinks:load", function() {
  const $chart = u('#route-chart');
  if ($chart.length === 0) {
    return;
  }

  const dataset = JSON.parse($chart.data('dataset'));

  const ctx = $chart.first();

  new Chart(ctx, {
    type: 'scatter',
    data: {
      datasets: [{
        data: dataset,
        borderColor: colors.theme['primary'],
        borderWidth: 2,
        pointRadius: 0,
        tension: 0,
        fill: false,
        showLine: true
      }]
    },
    options: {
      legend: false,
      tooltips: false,
      scales: {
        xAxes: [{
          // ticks: {
          //    min: 0,
          //    max: 10
          // },
          gridLines: {
            color: '#888',
            drawOnChartArea: false
          }
        }],
        yAxes: [{
          ticks: {
            min: 0,
            max: 1000,
            padding: 10
          },
          gridLines: {
            color: '#888',
            drawOnChartArea: false
          }
        }]
      }
    }
  });

});

