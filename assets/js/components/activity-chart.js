import { u } from 'umbrellajs';
import { colors, fonts } from './../variables.js';
import Highcharts from 'highcharts';

function parseData($element, name) {
  return JSON.parse($element.data(name));
}

function toMMSS(time) {
  const min = Math.floor(time);
  const sec = Math.round((time - min) * 60);
  const secStr = sec < 10 ? `0${sec}` : sec;
  return `${min}:${secStr}`;
}

function formatPoint(point, imperial) {
  const name = point.series.name;

  if (name === 'Elevation') {
    return `${name}: ${Math.round(point.y)} ${imperial ? 'ft' : 'm'}`;
  }

  if (name === 'Cadence') {
    return `${name}: ${Math.round(point.y)} steps/min`;
  }

  if (name === 'Heart Rate') {
    return `${name}: ${Math.round(point.y)} bpm`;
  }

  if (name === 'Pace') {
    return `${name}: ${toMMSS(point.y)} min/${imperial ? 'mile' : 'km'}`;
  }

  return '';
}

document.addEventListener("turbolinks:load", function() {
  const $chart = u('#activity-chart');
  if ($chart.length === 0) {
    return;
  }

  const imperial = parseData($chart, 'imperial');
  const altitude = parseData($chart, 'altitude');
  const cadence = parseData($chart, 'cadence');
  const distance = parseData($chart, 'distance');
  const heartrate = parseData($chart, 'heartrate');
  const pace = parseData($chart, 'velocity');

  const chart = Highcharts.chart('activity-chart', {
    chart: {
      alignTicks: true,
      type: 'spline',
      zoomType: 'x',
    },
    credits: false,
    title: false,
    xAxis: {
      data: [],
      minRange: 0.25,
      name: 'Distance',
      title: {
        text: imperial ? 'Distance (min/mile)' : 'Distance (min/km)',
      },
    },
    tooltip: {
      crosshairs: true,
      shared: true,
      shadow: false,
      backgroundColor: 'white',
      formatter: function() {
        const fields = this.points.map((point) => formatPoint(point, imperial));
        return `
          <strong>${this.x} ${imperial ? 'miles' : 'km'}</strong>
          <br />
          ${fields.join('<br />')}
        `;
      },
    },
    yAxis: [
      {
        id: 'elevation',
        lineWidth: 1,
        showEmpty: false,
        allowDecimals: false,
        title: {
          text: imperial ? 'Elevation (ft)' : 'Elevation (m)',
        },
      },
      {
        id: 'cadence',
        visible: false,
      },
      {
        id: 'heartrate',
        visible: false,
      },
      {
        id: 'pace',
        visible: false,
        max: 25,
        min: 3,
      },
    ],

    series: [
      {
        name: 'Elevation',
        type: 'area',
        data: altitude.map((x, idx) => [distance[idx], x]),
        color: colors.gray['300'],
        marker: {
          enabled: false,
          symbol: 'circle',
        },
        yAxis: 'elevation',
      },
      {
        name: 'Cadence',
        type: 'line',
        data: cadence.map((x, idx) => [distance[idx], x]),
        color: colors.theme['info'],
        marker: {
          enabled: false,
          symbol: 'circle',
        },
        yAxis: 'cadence',
      },
      {
        name: 'Heart Rate',
        type: 'line',
        data: heartrate.map((x, idx) => [distance[idx], x]),
        color: {
          linearGradient: { x1: 0, x2: 0, y1: 0, y2: 1 },
          stops: [
            [0, colors.red], // start
            [0.5, colors.orange], // middle
            [1, colors.yellow] // end
          ]
        },
        marker: {
          enabled: false,
          symbol: 'circle',
        },
        yAxis: 'heartrate',
      },
      {
        name: 'Pace',
        type: 'line',
        data: pace.map((x, idx) => [distance[idx], x]),
        color: colors.theme['success'],
        marker: {
          enabled: false,
          symbol: 'circle',
        },
        yAxis: 'pace',
      },
    ]
  });
});
