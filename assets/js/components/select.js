import SlimSelect from 'slim-select';

function init() {
  $('.slim-select').each((_, el) => {
    new SlimSelect({
      select: el,
    });
  });
}

window.addEventListener("phx:page-loading-stop", init);
