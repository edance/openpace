import { u } from 'umbrellajs';

function init() {
  u('.avatar img').each((image) => {
    if (image.complete && image.naturalHeight === 0) {
      image.classList.add("d-none");
    }
  });

  u('.avatar img').on('load', (x) => {
    const image = x.target;

    if (image.complete && image.naturalHeight === 0) {
      image.classList.add("d-none");
    }
  });
}

window.addEventListener("load", init);
window.addEventListener("phx:page-loading-stop", init);
