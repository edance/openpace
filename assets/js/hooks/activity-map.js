import * as d3 from "d3";
import mapboxgl from "mapbox-gl";

// Include the css for mapbox in the bundle
import "../../node_modules/mapbox-gl/dist/mapbox-gl.css";

mapboxgl.accessToken = window.MAPBOX_ACCESS_TOKEN;

export default {
  generateGeoJson() {
    let tp1 = this.trackpoints[0];

    const movingTrackpoints = this.trackpoints.filter((t) => t.moving);

    const color = d3.scaleSequential(
      d3.extent(movingTrackpoints, (t) => t.velocity),
      d3.interpolateMagma
    );

    const features = this.trackpoints.slice(1).map((tp2) => {
      const velocity = (tp2.velocity + tp1.velocity) / 2;

      const feature = {
        properties: {
          color: color(velocity),
        },
        geometry: {
          type: "LineString",
          coordinates: [
            [tp1.coordinates.lon, tp1.coordinates.lat],
            [tp2.coordinates.lon, tp2.coordinates.lat],
          ],
        },
      };

      tp1 = tp2;

      return feature;
    });

    return {
      id: "LineString",
      type: "line",
      source: {
        type: "geojson",
        data: {
          type: "FeatureCollection",
          features,
        },
      },
      layout: {
        "line-join": "round",
        "line-cap": "round",
      },
      paint: {
        "line-color": ["get", "color"],
        "line-width": 5,
      },
    };
  },

  mounted() {
    // Create a new map
    const map = new mapboxgl.Map({
      container: this.el,
      style: "mapbox://styles/mapbox/dark-v9",
      cooperativeGestures: true, // Disable scroll
    });

    // Add full screen buttons
    map.addControl(new mapboxgl.FullscreenControl());

    // Add navigation controls
    map.addControl(new mapboxgl.NavigationControl());

    this.handleEvent("trackpoints", ({ trackpoints }) => {
      this.trackpoints = trackpoints;

      const geojson = this.generateGeoJson();

      // Map coordinates to be handled by mapbox
      const coords = trackpoints.map((tp) => {
        return [tp.coordinates.lon, tp.coordinates.lat];
      });

      // Calculate the bounds of the map
      const bounds = coords.reduce(function (bounds, coord) {
        return bounds.extend(coord);
      }, new mapboxgl.LngLatBounds(coords[0], coords[0]));

      // Fit the bounds without an animation
      map.fitBounds(bounds, {
        easing: () => 1, // disable animation
        padding: 20,
      });

      map.on("load", function () {
        map.addLayer(geojson);
      });
    });
  },
};
