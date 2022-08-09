import { u } from 'umbrellajs';
import { colors, fonts } from './../variables.js';
import { calcDistance, calcFeet, roundTo } from '../utils';
import Highcharts from 'highcharts';
import { DateTime } from "luxon";

function parseData($element, name) {
  return JSON.parse($element.data(name));
}

function init() {
  const $chart = u('#overview-chart');
  if ($chart.length === 0) {
    return;
  }

  const summaries = parseData($chart, 'summaries');
  const imperial = parseData($chart, 'imperial');

  const weekCount = 24;
  const now = DateTime.now();
  const startDate = now.startOf("week").minus({ weeks: weekCount - 1 });
  const dates = [];

  for (let i = 0; i < weekCount; i++) {
    dates.push(startDate.plus({ weeks: i }).toMillis());
  }

  const runs = summaries.filter((x) => x.type.indexOf("Run") !== -1);
  const dateMap = {};

  runs.forEach((summary) => {
    const date = DateTime.fromISO(summary.start_at_local).startOf("week");
    const dateStr = date.toMillis();
    const entry = dateMap[dateStr];

    if (entry) {
      dateMap[dateStr] = {
        date: date.toMillis(),
        distance: entry.distance + summary.distance,
        duration: entry.duration + summary.duration,
        elevation_gain: entry.elevation_gain + summary.elevation_gain,
      };
    } else {
      dateMap[dateStr] = {
        date: date.toMillis(),
        distance: summary.distance,
        duration: summary.duration,
        elevation_gain: summary.elevation_gain,
      };
    }
  });

  const distances = dates.map((k) => {
    const entry = dateMap[k];
    return [k, calcDistance(entry ? entry.distance : 0, imperial, 1)];
  });

  const durations = dates.map((k) => {
    const entry = dateMap[k];
    return [k, entry ? roundTo(entry.duration / 60 / 60, 1) : 0];
  });

  const gains = dates.map((k) => {
    const entry = dateMap[k];
    return entry ? calcFeet(entry.elevation_gain, 1) : 0;
  });

  const minElevation = Math.min(...gains);
  const maxElevation = Math.max(...gains);

  const chart = Highcharts.chart('overview-chart', {
    chart: {
      alignTicks: true,
      zoomType: 'x',
      backgroundColor: 'none',
    },
    credits: false,
    title: false,
    legend: {
      itemStyle: {
        color: colors.gray['200'],
      },
      itemHoverStyle: {
        color: '#FFF'
      },
      itemHiddenStyle: {
        color: colors.gray['700'],
      },
    },
    xAxis: {
      type: 'datetime',
      lineColor: colors.gray['700'],
      gridLineColor: colors.gray['800'],
      labels: {
        style: {
          color: colors.gray['200'],
        }
      },
      tickColor: 'none',
    },
    yAxis: [
      {
        id: 'duration',
        visible: false,
        floor: 0,
      },
      {
        id: 'elevation',
        visible: false,
        floor: 0,
        min: minElevation,
        max: maxElevation * 3,
      },
      {
        id: 'distance',
        lineWidth: 1,
        showEmpty: false,
        allowDecimals: false,
        lineColor: colors.gray['700'],
        gridLineColor: colors.gray['800'],
        softMin: 0,
        softMax: 100,
        labels: {
          style: {
            color: colors.gray['200'],
          }
        },
        title: {
          text: imperial ? 'Distance (mi)' : 'Distance (km)',
          style: {
            color: colors.gray['200'],
          },
        },
      },
    ],
    tooltip: {
      crosshairs: true,
      shared: true,
      shadow: false,
      backgroundColor: 'white',
      valueDecimals: 1,
      xDateFormat: 'Week of %m-%d',
    },
    series: [
      {
        name: 'Elevation Gain',
        type: 'area',
        data: gains.map((x, idx) => [dates[idx], x]),
        borderWidth: 0,
        yAxis: 'elevation',
        marker: {
          enabled: false,
        },
        tooltip: {
          valueDecimals: 1,
          valueSuffix: imperial ? ' ft' : ' m',
        },
        color: {
          linearGradient: { x1: 0, x2: 0, y1: 0, y2: 1 },
          stops: [
            [0, colors.gray[300]], // start
            [1, colors.gray[200]] // end
          ]
        },
      },
      {
        name: 'Duration',
        type: 'column',
        data: durations,
        color: colors.theme['info'],
        borderWidth: 0,
        yAxis: 'duration',
        tooltip: {
          valueDecimals: 1,
          valueSuffix: ' hrs',
        },
      },
      {
        name: 'Distance',
        type: 'column',
        data: distances,
        color: colors.theme['primary'],
        borderWidth: 0,
        yAxis: 'distance',
        tooltip: {
          valueDecimals: 1,
          valueSuffix: imperial ? ' mi' : ' km',
        },
      },
    ]
  });
};

window.addEventListener("phx:page-loading-stop", init);
window.addEventListener("load", init);
