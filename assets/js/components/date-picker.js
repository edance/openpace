import flatpickr  from 'flatpickr';
// import rangePlugin from 'flatpickr/dist/plugins/rangePlugin';

import { u } from 'umbrellajs';

document.addEventListener("turbolinks:load", function() {
  u('.date-picker').each((el) => {
    const options = {
      inline: el.dataset["inline"],
    };

    if (el.dataset["range"]) {
      options["mode"] = "range";
    }

    flatpickr(el, options);
  });
});
