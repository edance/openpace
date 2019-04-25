import { u } from 'umbrellajs';

document.addEventListener('turbolinks:load', function() {
  const hideWarning = localStorage.getItem('dismissCookieWarning');
  const $cookieWarning = u('.cookie-warning');

  if (!hideWarning) {
    $cookieWarning.removeClass('d-none');
    $cookieWarning.addClass('show');
  }

  u('.cookie-warning .close').on('click', function() {
    localStorage.setItem('dismissCookieWarning', true);
  });
});
