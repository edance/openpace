import { u } from 'umbrellajs';
import { guessTimezone } from '../utils';

function init() {
  const timezone = guessTimezone();
  u('.timezone-hidden-input').attr('value', timezone);
};

window.addEventListener("phx:page-loading-stop", init);
window.addEventListener("load", init);
