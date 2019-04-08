import { u } from 'umbrellajs';
import Turbolinks from 'turbolinks';

import socket from '../socket';

const channel = socket.channel(`notification:${window.userId}`, {});
channel.join();
channel.on('history_loaded', () => {
  Turbolinks.visit('/dashboard/overview');
});

let timeout;

document.addEventListener("turbolinks:load", function() {
  if (u('.dashboard-loading').length === 0) {
    return;
  }

  timeout = setTimeout(() => Turbolinks.visit('/dashboard/overview'), 4000);
});

document.addEventListener('turbolinks:before-visit', () => clearTimeout(timeout));
