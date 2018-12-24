import { u } from 'umbrellajs';
import { guessTimezone } from '../utils';

document.addEventListener("turbolinks:load", function() {
  const useImperialMeasurements = guessTimezone().indexOf('America') !== -1;
  u('.imperial-hidden-input').attr('value', useImperialMeasurements);
});
