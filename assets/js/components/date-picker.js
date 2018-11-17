import flatpickr from 'flatpickr';

document.addEventListener("turbolinks:load", function() {
  flatpickr('.date-picker');
});
