import Chart from 'chart.js';
import { colors, fonts } from './../variables.js';

document.addEventListener("turbolinks:load", function() {
  const $chart = document.getElementById('chart-sales');

  new Chart($chart, {
    type: 'line',
    options: {
      responsive: true,
      maintainAspectRatio: false,
      defaultColor: colors.gray[600],
      defaultFontColor: colors.gray[600],
      defaultFontFamily: fonts.base,
      defaultFontSize: 13,
      layout: {
        padding: 0
      },
      legend: {
        display: false,
        position: 'bottom',
        labels: {
          usePointStyle: true,
          padding: 16
        }
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
        rectangle: {
          backgroundColor: colors.theme['warning']
        },
        arc: {
          backgroundColor: colors.theme['primary'],
          borderColor: colors.white,
          borderWidth: 4
        }
      },

      scales: {
        yAxes: [{
          gridLines: {
            color: colors.gray[900],
            zeroLineColor: colors.gray[900]
          },
          ticks: {
            callback: function(value) {
              if (!(value % 10)) {
                return '$' + value + 'k';
              }
            }
          }
        }]
      },
      tooltips: {
        callbacks: {
          label: function(item, data) {
            var label = data.datasets[item.datasetIndex].label || '';
            var yLabel = item.yLabel;
            var content = '';

            if (data.datasets.length > 1) {
              content += '<span class="popover-body-label mr-auto">' + label + '</span>';
            }

            content += '<span class="popover-body-value">$' + yLabel + 'k</span>';
            return content;
          }
        }
      }
    },
    data: {
      labels: ['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
      datasets: [{
        label: 'Performance',
        data: [0, 20, 10, 30, 15, 40, 20, 60, 60]
      }]
    }
  });
});
