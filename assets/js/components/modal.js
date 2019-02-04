document.addEventListener("turbolinks:load", function() {
  setTimeout(() => $('.modal[data-show="true"]').modal('show'), 1000);
});
