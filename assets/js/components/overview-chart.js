import { u } from 'umbrellajs';
import { colors, fonts } from './../variables.js';
import Highcharts from 'highcharts';

function parseData($element, name) {
  return JSON.parse($element.data(name));
}

document.addEventListener("turbolinks:load", function() {
  const $chart = u('#overview-chart');
  if ($chart.length === 0) {
    return;
  }

  const distance = parseData($chart, 'distance');
  const imperial = parseData($chart, 'imperial');

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
    },
    series: [
      {
        name: 'Distance',
        type: 'column',
        data: distance.map((x) => [Date.parse(x.date), x.distance]),
        color: colors.theme['primary'],
        borderWidth: 0,
        yAxis: 'distance',
      },
    ]
  });
});
