import { u } from 'umbrellajs';

u(document).on('submit', 'form', function(event) {
  const $form = u(this);
  const $button = $form.find('.btn-spinner');
  $button.attr('disabled', true);
  $button.html(`
    <span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>
    <span class="sr-only">Loading...</span>
  `);
});
