import { u } from 'umbrellajs';

function fadeOut(alert) {
  alert.removeClass('show');
}

function removeElement(alert) {
  alert.remove();
}

document.addEventListener('turbolinks:load', function() {
  const timeout = setTimeout(() => {
    const alert = u('.alert');
    fadeOut(alert);
    setTimeout(() => removeElement(alert), 150);
  }, 4000);
});
