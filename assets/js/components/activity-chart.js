import { u } from 'umbrellajs';
import { colors, fonts } from './../variables.js';
import * as vega from 'vega';

document.addEventListener("turbolinks:load", function() {
  const $chart = u('#activity-chart');
  if ($chart.length === 0) {
    return;
  }

  const spec = {
    "$schema": "https://vega.github.io/schema/vega/v5.json",
    "autosize": {
      "type": "fit",
      "contains": "padding"
    },
    "signals": [
      {
        "name": "x_scale_move",
        "on": [
          {
            "events": "mousemove",
            "update": "invert('xscale', x())"
          }
        ]
      },
    ],
    "data": [
      {
        "name": "table",
        "values": JSON.parse($chart.data('trackpoints')),
        "transform": [
          {
            "type": "window",
            "as": ["altitude"],
            "ops": ["average"],
            "fields": ["altitude"],
            "frame": [-5, 5]
          },
          {
            "type": "window",
            "as": ["cadence"],
            "ops": ["average"],
            "fields": ["cadence"],
            "frame": [-5, 5]
          },
          {
            "type": "window",
            "as": ["heartrate"],
            "ops": ["average"],
            "fields": ["heartrate"],
            "frame": [-5, 5]
          },
          {
            "type": "window",
            "as": ["velocity"],
            "ops": ["average"],
            "fields": ["velocity"],
            "frame": [-5, 5]
          },
        ]
      }
    ],
    "scales": [
      {
        "name": "xscale",
        "domain": {"data": "table", "field": "distance"},
        "range": "width",
        "round": true
      },
      {
        "name": "yscale2",
        "domain": {"data": "table", "field": "cadence"},
        "nice": true,
        "range": "height"
      },
      {
        "name": "yscale-hr",
        "domain": {"data": "table", "field": "heartrate"},
        "nice": true,
        "range": "height"
      },
      {
        "name": "yscale-velocity",
        "domain": {"data": "table", "field": "velocity"},
        "nice": true,
        "range": "height"
      },
      {
        "name": "yscale",
        "domain": {"data": "table", "field": "altitude"},
        "nice": true,
        "range": "height"
      }
    ],

    "axes": [
      { "orient": "bottom", "scale": "xscale" },
      { "orient": "left", "scale": "yscale" },
    ],

    "marks": [
      {
        type: "rule",
        encode: {
          update: {
            x: {
              scale: "xscale",
              signal: "x_scale_move",
              offset: 0.5
            },
            y: { value: 0 },
            y2: { signal: "height" },
            stroke: { value: colors.gray['600'] },
            strokeWidth: { value: 2 },
            strokeDash: { value: [8, 4] },
            opacity: { value: 1 },
          }
        }
      },
      {
        "type": "line",
        "from": {"data":"table"},
        "encode": {
          "enter": {
            "stroke": {"value": colors.gray['400'] },
            "x": {"scale": "xscale", "field": "distance"},
            "y": {"scale": "yscale", "field": "altitude"},
            interpolate: "basis",
          },
        }
      },
      {
        "type": "line",
        "from": {"data":"table"},
        "encode": {
          "enter": {
            "stroke": {"value": colors.theme['info']},
            "x": {"scale": "xscale", "field": "distance"},
            "y": {"scale": "yscale2", "field": "cadence"},
            interpolate: "basis",
          },
        }
      },
      {
        "type": "line",
        "from": {"data":"table"},
        "encode": {
          "enter": {
            "stroke": {"value": colors.theme['danger'] },
            "x": {"scale": "xscale", "field": "distance"},
            "y": {"scale": "yscale-hr", "field": "heartrate"},
            interpolate: "basis",
          },
        }
      },
      {
        "type": "line",
        "from": {"data":"table"},
        "encode": {
          "enter": {
            "stroke": {"value": colors.theme['yellow']},
            "x": {"scale": "xscale", "field": "distance"},
            "y": {"scale": "yscale-velocity", "field": "velocity"},
            interpolate: "basis",
          },
        }
      },
    ]
  };


  const view = new vega.View(vega.parse(spec), {
    renderer:  'canvas',  // renderer (canvas or svg)
    container: '#activity-chart',   // parent DOM container
    hover:     true       // enable hover processing
  });

  const resize = () => {
    const width = $chart.size().width;
    const height = $chart.size().height;

    // debugger;
    view
      .height(height)
      .width(width)
      .runAsync();
  };

  window.addEventListener('resize', resize);

  resize();
});
