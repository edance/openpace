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
    "width": 800,
    "height": 400,
    "padding": 5,

    "data": [
      {
        "name": "table",
        "values": JSON.parse($chart.data('trackpoints'))
      }
    ],

    "signals": [
      {
        "name": "tooltip",
        "value": {},
        "on": [
          {"events": "rect:mouseover", "update": "datum"},
          {"events": "rect:mouseout",  "update": "{}"}
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
      { "orient": "right", "scale": "yscale2" },
      { "orient": "right", "scale": "yscale-hr", "offset": 50 }
    ],

    "marks": [
      {
        "type": "line",
        "from": {"data":"table"},
        "encode": {
          "enter": {
            "x": {"scale": "xscale", "field": "distance"},
            "y": {"scale": "yscale", "field": "altitude"}
          }
        }
      },
      {
        "type": "line",
        "from": {"data":"table"},
        "encode": {
          "enter": {
            "stroke": {"value": colors.theme['info']},
            "x": {"scale": "xscale", "field": "distance"},
            "y": {"scale": "yscale2", "field": "cadence"}
          }
        }
      },
      {
        "type": "line",
        "from": {"data":"table"},
        "encode": {
          "enter": {
            "stroke": {"value": colors.theme['danger'] },
            "x": {"scale": "xscale", "field": "distance"},
            "y": {"scale": "yscale-hr", "field": "heartrate"}
          }
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
          }
        }
      },
    ]
  };


  const view = new vega.View(vega.parse(spec), {
    renderer:  'canvas',  // renderer (canvas or svg)
    container: '#activity-chart',   // parent DOM container
    hover:     true       // enable hover processing
  });
  view.runAsync();
});
