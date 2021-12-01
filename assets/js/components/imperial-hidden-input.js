import { u } from 'umbrellajs';
import { guessTimezone } from '../utils';

function init() {
  const useImperialMeasurements = guessTimezone().indexOf('America') !== -1;
  u('.imperial-hidden-input').attr('value', useImperialMeasurements);
};

window.addEventListener("phx:page-loading-stop", init);
window.addEventListener("load", init);
