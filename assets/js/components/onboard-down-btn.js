$('.onboard-down-btn').on('click', (e) => {
  const id = e.currentTarget.href.replace(/^.*?(#|$)/,'');
  const $div = $(`#${id}`);

  e.preventDefault();

  $('html, body').animate({
    scrollTop: $div.offset().top
  });
});
