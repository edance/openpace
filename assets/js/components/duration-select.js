import { u } from 'umbrellajs';

document.addEventListener("turbolinks:load", function() {
  u('.duration-select').each(el => {
    const $input = u(el).find('input');
    const value = parseInt($input.attr('value'), 10);
    if (isNaN(value)) {
      return;
    }

    u(el).find('select').each(select => {
      if (select.name == 'seconds') {
        select.value = value % 60;
      }
      if (select.name == 'minutes') {
        select.value = Math.floor(value / 60 % 60);
      }
      if (select.name == 'hours') {
        select.value = Math.floor(value / 60 / 60 % 60);
      }
    });
  });

  u('.duration-select select').on('change', (e) => {
    const $component = u(e.target).closest('.duration-select');
    let total = 0;

    $component.find('select').map((el) => {
      let multiplier = 1;
      const value = parseInt(el.value);

      if (isNaN(value)) {
        return;
      }
      if (el.name.indexOf('minutes') !== -1) {
        multiplier = 60;
      }
      if (el.name.indexOf('hours') !== -1) {
        multiplier = 60 * 60;
      }
      total += parseInt(el.value, 10) * multiplier;
    });

    $component.find('input').attr('value', total);
  });
});
