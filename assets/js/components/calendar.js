import { u } from 'umbrellajs';
import { formatDate } from '../utils';

document.addEventListener("turbolinks:load", function() {
  const today = new Date();
  const label = u(`*[data-date="${formatDate(today)}"]`);
  label.addClass('active');
});
