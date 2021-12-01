function init() {
  setTimeout(() => $('.modal[data-show="true"]').modal('show'), 1000);
};

window.addEventListener("phx:page-loading-stop", init);
window.addEventListener("load", init);
