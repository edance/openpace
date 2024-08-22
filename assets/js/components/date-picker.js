import flatpickr  from 'flatpickr';

function load() {
  document.querySelectorAll('.date-picker').forEach((el) => {
    const options = {
      inline: el.dataset["inline"],
    };

    if (el.dataset["range"]) {
      options["mode"] = "range";
    }

    flatpickr(el, options);
  });
}

window.addEventListener("load", load);
window.addEventListener("phx:page-loading-stop", load);
