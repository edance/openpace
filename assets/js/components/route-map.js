import { u } from 'umbrellajs';
import mapboxgl from 'mapbox-gl';
import { colors, fonts } from './../variables.js';

mapboxgl.accessToken = window.MAPBOX_ACCESS_TOKEN;

document.addEventListener("turbolinks:load", function() {
  const $mapCanvas = u('#map-canvas');
  if (u('#map-canvas').length === 0) {
    return;
  }

  const coordinates = JSON.parse($mapCanvas.data('coordinates'));
  const markers = JSON.parse($mapCanvas.data('markers'));

  const bounds = coordinates.reduce(function(bounds, coord) {
    return bounds.extend(coord);
  }, new mapboxgl.LngLatBounds(coordinates[0], coordinates[0]));

  const map = new mapboxgl.Map({
    center: bounds.getCenter(),
    container: 'map-canvas',
    style: 'mapbox://styles/mapbox/outdoors-v9',
  });

  map.fitBounds(bounds, {
    easing: () => 1, // disable animation
    padding: 20
  });

  map.scrollZoom.disable();
  map.addControl(new mapboxgl.NavigationControl());

  map.on('load', function () {
    map.addLayer({
      "id": "LineString",
      "type": "line",
      "source": {
        "type": "geojson",
        "data": {
          "type": "Feature",
          "properties": {},
          "geometry": {
            "type": "LineString",
            "coordinates": coordinates,
          }
        }
      },
      "layout": {
        "line-join": "round",
        "line-cap": "round"
      },
      "paint": {
        "line-color": colors.theme['primary'],
        "line-width": 5
      }
    });
  });
});
