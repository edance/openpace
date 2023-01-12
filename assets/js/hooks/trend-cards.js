import * as d3 from "d3";
import { formatNumber } from "../utils";

export default {
  mounted() {
    this.handleEvent("summaries", ({ summaries }) => {
      const data = summaries.filter((d) => d.type === "Run");

      const totalDistance = d3.sum(data, (d) => d.distance);
      const totalDuration = d3.sum(data, (d) => d.duration) / 60 / 60;
      const elevationGain = d3.sum(data, (d) => d.elevation_gain);
      const runCount = data.length;

      this.animateAmount("#total-distance", totalDistance);
      this.animateAmount("#total-duration", totalDuration);
      this.animateAmount("#elevation-gain", elevationGain);
      this.animateAmount("#run-count", runCount);
    });
  },

  animateAmount(id, amount) {
    const text = d3.select(id);

    text
      .transition()
      .tween("text", function () {
        const selection = d3.select(this); // selection of node being transitioned
        const interpolator = d3.interpolateNumber(0, amount); // d3 interpolator

        return function (t) {
          selection.text(formatNumber(interpolator(t)));
        }; // return value
      })
      .duration(1000);
  },
};
