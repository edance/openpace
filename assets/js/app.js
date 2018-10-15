// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import 'jquery-ujs';
import Turbolinks from 'turbolinks';
Turbolinks.start();

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket";

// DatePicker
document.addEventListener("turbolinks:load", function() {
  flatpickr('.date-picker', { inline: true, static: true });

  // jquery-ujs handles deletes incorrectly
  $('a[data-to]').each((idx, el) => el.href = el.dataset['to']);
})
