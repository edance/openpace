import flatpickr  from 'flatpickr';
// import rangePlugin from 'flatpickr/dist/plugins/rangePlugin';

import { u } from 'umbrellajs';

function load() {
  u('.date-picker').each((el) => {
    const options = {
      inline: el.dataset["inline"],
    };

    if (el.dataset["range"]) {
      options["mode"] = "range";
    }

    flatpickr(el, options);
  });
}

window.addEventListener("phx:page-loading-stop", load);
