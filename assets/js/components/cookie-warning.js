import { u } from 'umbrellajs';

document.addEventListener('turbolinks:load', function() {
  const hideWarning = localStorage.getItem('dismissCookieWarning');

  if (!hideWarning) {
    u('.cookie-warning').addClass('show');
  }

  u('.cookie-warning .close').on('click', function() {
    localStorage.setItem('dismissCookieWarning', true);
  });
});
