import Chart from 'chart.js';
import { u } from 'umbrellajs';
import { colors, fonts } from './../variables.js';

document.addEventListener("turbolinks:load", function() {
  const $chart = u('#route-chart');
  if ($chart.length === 0) {
    return;
  }

  const dataset = JSON.parse($chart.data('dataset'));
  const xAxis = JSON.parse($chart.data('x-axis'));
  const yAxis = JSON.parse($chart.data('y-axis'));

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
      animation: { duration: 0 }, // Disable animation
      scales: {
        xAxes: [{
          ticks: {
            min: xAxis.min,
            max: xAxis.max,
            callback: function(value, index, values) {
              return `${value} ${xAxis.label}`;
            },
          },
          gridLines: {
            color: '#888',
            drawOnChartArea: false
          }
        }],
        yAxes: [{
          ticks: {
            min: yAxis.min,
            max: yAxis.max,
            callback: function(value, index, values) {
              return `${value} ${yAxis.label}`;
            },
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

