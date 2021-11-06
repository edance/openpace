import { u } from 'umbrellajs';

document.addEventListener("turbolinks:load", function() {
  const $input = u('.copy-input input');

  $input.on("click", (e) => {
    const node = u(e.target).parent('.copy-input').find('input').first();

    /* Select the text field */
    node.select();
    node.setSelectionRange(0, 99999); /* For mobile devices */

    /* Copy the text inside the text field */
    navigator.clipboard.writeText(node.value);
  });
});
