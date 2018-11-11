import { u } from 'umbrellajs';
import flatpickr from 'flatpickr';

document.addEventListener("turbolinks:load", function() {
  u('.flatpickr-calendar').remove();
  flatpickr('.date-picker', { inline: true, static: true });
});
