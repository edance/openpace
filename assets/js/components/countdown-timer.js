import { u } from 'umbrellajs';

document.addEventListener("turbolinks:load", function() {
  u('.countdown-timer').each(el => {
    const date = new Date(el.dataset['date']);

    setInterval(function() {

      // Get todays date and time
      const now = new Date().getTime();

      // Find the distance between now and the count down date
      const distance = date - now;

      // Time calculations for days, hours, minutes and seconds
      const days = Math.floor(distance / (1000 * 60 * 60 * 24));
      const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
      const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
      const seconds = Math.floor((distance % (1000 * 60)) / 1000);

      el.innerHTML = `${days}d ${hours}h ${minutes}m ${seconds}s`;
    }, 1000);
  });
});
