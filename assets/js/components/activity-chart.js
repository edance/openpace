import { u } from 'umbrellajs';
import { colors, fonts } from './../variables.js';
import Highcharts from 'highcharts';

function parseData($element, name) {
  return JSON.parse($element.data(name));
}

function formatSecs(seconds) {
  const sec = Math.round(seconds % 60);
  const min = Math.round(seconds / 60);
  const secStr = sec < 10 ? `0${sec}` : sec;
  return `${min}:${secStr}`;
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
    return `${name}: ${toMMSS(point.y)} min/${imperial ? 'mi' : 'km'}`;
  }

  return '';
}

function init() {
  const $chart = u('#activity-chart');
  if ($chart.length === 0) {
    return;
  }

  const imperial = parseData($chart, 'imperial');
  const altitude = parseData($chart, 'altitude');
  const minAltitude = Math.min(...altitude);
  const maxAltitude = Math.max(...altitude);
  const cadence = parseData($chart, 'cadence');
  const distance = parseData($chart, 'distance');
  const heartrate = parseData($chart, 'heartrate');
  const time = parseData($chart, 'time');
  const pace = parseData($chart, 'velocity');

  const xData = distance.length == 0 ? time : distance;
  const distanceLabel = imperial ? 'mi' : 'km';

  const distanceAxis = {
    data: [],
    minRange: 0.25,
    visible: false,
    name: 'Distance',
    title: {
      text: `Distance (min/${distanceLabel})`,
    },
  };

  const timeAxis = {
    tickInterval: 5 * 60, // 15 min
    labels: {
      formatter: function() {
        return formatSecs(this.value);
      },
    },
    title: {
      text: 'Time'
    }
  };

  const chart = Highcharts.chart('activity-chart', {
    chart: {
      alignTicks: true,
      type: 'spline',
      zoomType: 'x',
    },
    credits: false,
    title: false,
    plotOptions: {
      area: {
        threshold: -9999
      }
    },
    xAxis: distance.length ? distanceAxis : timeAxis,
    tooltip: {
      crosshairs: true,
      shared: true,
      shadow: false,
      backgroundColor: 'white',
      formatter: function() {
        const fields = this.points.map((point) => formatPoint(point, imperial));
        const x = distance.length ? `${this.x} ${distanceLabel}` : formatSecs(this.x);
        return `
          <strong>${x}</strong>
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
        offset: 0,
        floor: minAltitude,
        min: minAltitude,
        max: maxAltitude * 5,
      },
      {
        id: 'cadence',
        visible: false,
        min: 0,
        max: 200,
      },
      {
        id: 'heartrate',
        visible: distance.length == 0,
        title: {
          text: 'Heartrate (bpm)',
        },
        min: 0,
        max: 220,
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
        data: altitude.map((x, idx) => [xData[idx], x]),
        lineWidth: 0,
        color: {
          linearGradient: { x1: 0, x2: 0, y1: 0, y2: 1 },
          stops: [
            [0, colors.gray[300]], // start
            [1, colors.gray[200]] // end
          ]
        },
        marker: {
          enabled: false,
          symbol: 'circle',
        },
        yAxis: 'elevation',
      },
      {
        name: 'Cadence',
        type: 'line',
        data: cadence.map((x, idx) => [xData[idx], x]),
        color: colors.theme['info'],
        hidden: true,
        marker: {
          enabled: false,
          symbol: 'circle',
        },
        yAxis: 'cadence',
      },
      {
        name: 'Heart Rate',
        type: 'line',
        data: heartrate.map((x, idx) => [xData[idx], x]),
        color: {
          linearGradient: { x1: 0, x2: 0, y1: 0, y2: 1 },
          stops: [
            [0, colors.red], // start
            [0.5, colors.orange], // middle
            [1, colors.yellow] // end
          ]
        },
        marker: {
          symbol: 'circle',
        },
        yAxis: 'heartrate',
      },
      {
        name: 'Pace',
        type: 'line',
        data: pace.map((x, idx) => [xData[idx], x]),
        color: colors.theme['success'],
        marker: {
          symbol: 'circle',
        },
        yAxis: 'pace',
      },
    ]
  });
};

window.addEventListener("phx:page-loading-stop", init);
window.addEventListener("load", init);
