import SlimSelect from 'slim-select';
import { parseDistance } from '../utils';

function init() {
  $('.distance-select').each((_, el) => {
    new SlimSelect({
      select: el,
      // Optional - In the event you want to alter/validate it as a return value
      addable: function (value) {
        const distance = parseDistance(value);

        // return false or null if you do not want to allow value to be submitted
        if (distance === null) { return false; }

        // Optional - Return a valid data object. See methods/setData for list of valid options
        return {
          text: value,
          value: distance,
        };
      }
    });
  });
}

window.addEventListener("phx:page-loading-stop", init);
