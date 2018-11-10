import { u } from 'umbrellajs';

document.addEventListener("turbolinks:load", function() {
  u('.flatpickr-calendar').remove();
  flatpickr('.date-picker', { inline: true, static: true });
});
