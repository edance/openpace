import { u } from 'umbrellajs';

document.addEventListener("turbolinks:load", function() {
  u('.site-nav-toggler').on('click', function() {
    u('.site-nav').toggleClass('active');
  });
});
