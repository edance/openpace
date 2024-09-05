function init() {
  document.querySelectorAll(".avatar img").forEach((image) => {
    if (image.complete && image.naturalHeight === 0) {
      image.classList.add("hidden");
    }

    image.addEventListener("load", function (x) {
      const target = x.target;
      if (target.complete && target.naturalHeight === 0) {
        target.classList.add("hidden");
      }
    });
  });
}

window.addEventListener("load", init);
window.addEventListener("phx:page-loading-stop", init);
