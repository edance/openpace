import { u } from 'umbrellajs';
// import "../../node_modules/mapbox-gl/dist/mapbox-gl.css";
import mapboxgl from 'mapbox-gl';
import { colors, fonts } from './../variables.js';

mapboxgl.accessToken = window.MAPBOX_ACCESS_TOKEN;

function addLineString(map, coordinates) {
  map.addLayer({
    id: "LineString",
    type: "line",
    source: {
      type: "geojson",
      data: {
        type: "Feature",
        properties: {},
        geometry: {
          type: "LineString",
          coordinates: coordinates,
        }
      }
    },
    layout: {
      "line-join": "round",
      "line-cap": "round"
    },
    paint: {
      "line-color": colors.theme['primary'],
      "line-width": 5
    }
  });
}

function init() {
  const $mapCanvas = u('.activity-map');
  if ($mapCanvas.length === 0) {
    return;
  }

  const coordinates = JSON.parse($mapCanvas.data('coordinates'));
  const geojson = JSON.parse($mapCanvas.data('geojson'));

  const bounds = coordinates.reduce(function(bounds, coord) {
    return bounds.extend(coord);
  }, new mapboxgl.LngLatBounds(coordinates[0], coordinates[0]));

  const map = new mapboxgl.Map({
    center: bounds.getCenter(),
    container: $mapCanvas.first(),
    style: 'mapbox://styles/mapbox/light-v9',
  });

  map.fitBounds(bounds, {
    easing: () => 1, // disable animation
    padding: 20
  });

  map.scrollZoom.disable();
  map.addControl(new mapboxgl.NavigationControl());

  map.on('load', function () {
    map.addLayer(geojson);
  });
};

window.addEventListener("phx:page-loading-stop", init);
window.addEventListener("load", init);
