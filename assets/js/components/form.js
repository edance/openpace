// Found in changelog
// https://github.com/thechangelog/changelog.com/blob/master/assets/app/app.js#L121

import 'whatwg-fetch';
import Turbolinks from 'turbolinks';
import { u } from 'umbrellajs';

u(document).on('submit', 'form', function(event) {
  const form = u(this);

  if (form.data("remote") !== "true") {
    return;
  }

  event.preventDefault();

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
