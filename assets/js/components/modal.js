document.addEventListener("turbolinks:load", function() {
  setTimeout(() => $('.modal[data-show="true"]').modal('show'), 1000);
});

document.addEventListener('turbolinks:before-visit', function() {
  $('.modal').modal('hide');
});
