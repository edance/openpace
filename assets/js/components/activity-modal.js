import 'whatwg-fetch';
import Turbolinks from 'turbolinks';
import { u } from 'umbrellajs';

document.addEventListener("turbolinks:load", function() {
  const $form = u('#activity-modal form');

  $form.on('submit', (e) => {
    e.preventDefault();

    const action = $form.attr('action');
    const method = $form.attr('method');
    const options = {method: method, body: new FormData($form.first())};
    const url = location.href;

    fetch(action, options)
      .then(resp => Promise.all([resp, resp.text()]))
      .then(([resp, body]) => {
        if (resp.status === 200 || resp.status === 201) {
          $('#activity-modal').modal('hide');
          Turbolinks.visit(url, {action: 'replace'});
        } else {
          const html = u(body).filter('form').html();
          $form.html(html);
        }
      });
  });
});
