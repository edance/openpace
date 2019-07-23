import { u } from 'umbrellajs';
import Sortable from 'sortablejs';

document.addEventListener('turbolinks:load', function() {
  $('ul.plan-date').map(function(_, x) {
    Sortable.create(x, {
      group: 'shared', // set both lists to same group
      animation: 150,
      onEnd: function(evt) {
        const id = evt.item.dataset['id'];
        const $dateEl = evt.to;
        const day = parseInt($dateEl.dataset['day'], 10);
        const week = parseInt($dateEl.dataset['week'], 10);
        const position = (week - 1) * 7 + day - 1;
        console.log(`${id} moved to pos: ${position}, idx: ${evt.newIndex}`);
      },
    });
  });
});
