function init() {
  setTimeout(() => {
    document.querySelectorAll('[data-auto-hide="true"]').forEach((alert) => {
      alert.remove();
    });
  }, 4000);
};

window.addEventListener("phx:page-loading-stop", init);
window.addEventListener("load", init);
