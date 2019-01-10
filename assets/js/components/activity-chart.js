import Chart from 'chart.js';
import { u } from 'umbrellajs';
import { colors, fonts } from './../variables.js';

document.addEventListener("turbolinks:load", function() {
  const $chart = u('#activity-chart');
  if ($chart.length === 0) {
    return;
  }

  const altitude = JSON.parse($chart.data('altitude'));
  const distance = JSON.parse($chart.data('distance'));
  const heartrate = JSON.parse($chart.data('heartrate'));

  let options = {
    responsive: true,
    maintainAspectRatio: false,
    scales: {
      xAxes: [{
        ticks: {
          min: 0,
          stepSize: 0.5
        }
      }]
    }
  };

  new Chart($chart.first(), {
    type: 'line',
    data: {
      datasets: [
        {
          label: 'Heart Rate',
          data: heartrate,
        },
        {
          label: 'Elevation',
          data: altitude,
        }
      ],
      labels: distance,
    },
    options: options,
  });
});
