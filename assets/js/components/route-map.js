import { u } from 'umbrellajs';
import mapboxgl from 'mapbox-gl';

mapboxgl.accessToken = window.MAPBOX_ACCESS_TOKEN;

document.addEventListener("turbolinks:load", function() {
  if (u('#map-canvas').length === 0) {
    return;
  }

  new mapboxgl.Map({
    container: 'map-canvas',
    style: 'mapbox://styles/mapbox/streets-v11'
  });
});
