import { u } from 'umbrellajs';

u(document).on('click', '.btn-calendar-activity', function(event) {
  $('#activity-modal').modal('show');
});
