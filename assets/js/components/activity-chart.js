import { u } from 'umbrellajs';
import { colors, fonts } from './../variables.js';
import Highcharts from 'highcharts';

document.addEventListener("turbolinks:load", function() {
  const $chart = u('#activity-chart');
  if ($chart.length === 0) {
    return;
  }

  const data = JSON.parse($chart.data('trackpoints'));

  const altitude = data.map(x => [x.distance, x.altitude]);
  const heartrate = data.map(x => [x.distance, x.heartrate]);
  const cadence = data.map(x => [x.distance, x.cadence]);
  const velocity = data.map(x => [x.distance, x.velocity]);

  const chart = Highcharts.chart('activity-chart', {
    chart: {
      alignTicks: true,
      plotBackgroundColor: null,
      plotBorderWidth: 0,
      type: 'spline',
      spacingRight: 0,
      zoomType: 'xy',
    },
    credits: false,
    title: false,
    xAxis: {
      enabled: 'true',
      data: [],
      minRange: 0.25,
      name: 'Distance',
      title: {
        text: 'Distance (min/mile)',
        style: {
          color: colors['primary'],
        }
      },
    },
    tooltip: {
      crosshairs: true,
      shared: true,
    },
    series: [
      {
        name: 'Elevation',
        data: altitude,
        marker: {
          enabled: false,
          symbol: 'circle',
        },
      },
      {
        name: 'Heart Rate',
        data: heartrate,
        marker: {
          enabled: false,
          symbol: 'circle',
        },
      },
      {
        name: 'Cadence',
        data: cadence,
        marker: {
          enabled: false,
          symbol: 'circle',
        },
      },
      {
        type: 'line',
        name: 'Pace',
        data: velocity,
        marker: {
          enabled: false,
          symbol: 'circle',
        },
      },
    ]
  });
});
