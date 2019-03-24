import { u } from 'umbrellajs';
import mapboxgl from 'mapbox-gl';

mapboxgl.accessToken = window.MAPBOX_ACCESS_TOKEN;

document.addEventListener("turbolinks:load", function() {
  const $mapCanvas = u('#map-canvas');
  if (u('#map-canvas').length === 0) {
    return;
  }

  let coordinates = JSON.parse($mapCanvas.data('coordinates'));

  const bounds = coordinates.reduce(function(bounds, coord) {
    return bounds.extend(coord);
  }, new mapboxgl.LngLatBounds(coordinates[0], coordinates[0]));

  const map = new mapboxgl.Map({
    center: bounds.getCenter(),
    container: 'map-canvas',
    style: 'mapbox://styles/mapbox/light-v9',
  });

  map.fitBounds(bounds, {
    easing: () => 1, // disable animation
    padding: 20
  });

  map.scrollZoom.disable();

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
        "line-color": "#BF93E4",
        "line-width": 5
      }
    });
  });
});
