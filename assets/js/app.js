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
import 'bootstrap';
import 'whatwg-fetch';
import { u } from 'umbrellajs';

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".
import './components/base';

// Turbolinks
import Turbolinks from 'turbolinks';
Turbolinks.start();

// jquery-ujs handles deletes incorrectly
document.addEventListener('turbolinks:load', function() {
  $('a[data-to]').each((idx, el) => el.href = el.dataset['to']);
});


// Found in changelog
// https://github.com/thechangelog/changelog.com/blob/master/assets/app/app.js#L121
// submit forms with Turbolinks
u(document).on('submit', 'form', function(event) {
  event.preventDefault();

  const form = u(this);
  const action = form.attr('action');
  const method = form.attr('method');
  const referrer = location.href;

  if (method == 'get') {
    return Turbolinks.visit(`${action}?${form.serialize()}`);
  }

  const options = {method: method, body: new FormData(form.first()), headers: {'Turbolinks-Referrer': referrer}};
  const andThen = ([resp, body]) => {
    const snapshot = Turbolinks.Snapshot.wrap(body);
    Turbolinks.controller.cache.put(resp.url, snapshot);
    Turbolinks.visit(resp.url, {action: 'restore'});
  };

  fetch(action, options)
    .then(resp => Promise.all([resp, resp.text()]))
    .then(andThen);
});
