import { u } from 'umbrellajs';
import { guessTimezone } from '../utils';

document.addEventListener("turbolinks:load", function() {
  const timezone = guessTimezone();
  u('.timezone-hidden-input').attr('value', timezone);
});
