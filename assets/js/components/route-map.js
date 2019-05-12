import { u } from 'umbrellajs';
import mapboxgl from 'mapbox-gl';

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

    const features = markers.map((latlng, idx) => {
      return {
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "coordinates": latlng
        },
        "properties": {
          "title": `${idx}`,
          "icon": "volcano"
        }
      };
    });

    map.addLayer({
      "id": "points",
      "type": "symbol",
      "source": {
        "type": "geojson",
        "data": {
          "type": "FeatureCollection",
          "features": features
        }
      },
      "layout": {
        "icon-image": "{icon}-15",
        "text-field": "{title}",
        "text-font": ["Open Sans Semibold", "Arial Unicode MS Bold"],
        "text-offset": [0, 0.6],
        "text-anchor": "top"
      }
    });
  });
});
