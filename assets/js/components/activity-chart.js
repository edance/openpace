import Chart from 'chart.js';
import 'chartjs-plugin-crosshair';
import { u } from 'umbrellajs';
import { colors, fonts } from './../variables.js';

function generateDataset(shift, label, color) {
  var data = [];
  var x = 0;
  while (x < 30) {
    data.push({ x: x, y: Math.sin(shift + x / 3) });
    x += Math.random();
  }
  var dataset = {
    backgroundColor: color,
    borderColor: color,
    showLine: true,
    fill: true,
    pointRadius: 2,
    label: label,
    data: data,
    lineTension: 0,
    interpolate: true
  };
  return dataset;
}

document.addEventListener("turbolinks:load", function() {
  const $chart = u('.activity-chart');

  if ($chart.length === 0) {
    return;
  }


  var chart2 = new Chart(document.getElementById("chart2").getContext("2d"), {
    type: "scatter",
    options: {
      tooltips: {
        mode: "interpolate",
        intersect: false,
        callbacks: {
          title: function(a, d) {
            return a[0].xLabel.toFixed(2);
          },
          label: function(i, d) {
            return (
              d.datasets[i.datasetIndex].label + ": " + i.yLabel.toFixed(2)
            );
          }
        }
      },
      plugins: {
        crosshair: {
          line: {
            color: '#000',  // crosshair line color
            width: 1        // crosshair line width
          },
        },
      },
    },
    data: {
      datasets: [generateDataset(0, "A", "red")]
    }
  });

  var chart3 = new Chart(document.getElementById("chart3").getContext("2d"), {
    type: "scatter",
    options: {
      tooltips: {
        mode: "interpolate",
        intersect: false,
        callbacks: {
          title: function(a, d) {
            return a[0].xLabel.toFixed(2);
          },
          label: function(i, d) {
            return (
              d.datasets[i.datasetIndex].label + ": " + i.yLabel.toFixed(2)
            );
          }
        }
      }
    },
    data: {
      datasets: [generateDataset(1, "B", "green")]
    }
  });

  var chart4 = new Chart(document.getElementById("chart4").getContext("2d"), {
    type: "scatter",
    options: {
      tooltips: {
        mode: "interpolate",
        intersect: false,
        callbacks: {
          title: function(a, d) {
            return a[0].xLabel.toFixed(2);
          },
          label: function(i, d) {
            return (
              d.datasets[i.datasetIndex].label + ": " + i.yLabel.toFixed(2)
            );
          }
        }
      }
    },
    data: {
      datasets: [generateDataset(1, "C", "blue")]
    }
  });
});

