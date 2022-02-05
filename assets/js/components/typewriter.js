import GraphemeSplitter from 'grapheme-splitter';
import Typewriter from 'typewriter-effect/dist/core';

window.addEventListener('load', (_event) => {
  const $el = document.querySelector('.namer-example-txt');

  if (!$el) {
    return;
  }

  const stringSplitter = function(string) {
    const splitter = new GraphemeSplitter();
    return splitter.splitGraphemes(string);
  };

  const typewriter = new Typewriter($el, {
    loop: true,
    stringSplitter: stringSplitter
  });

  typewriter.typeString('Morning Run')
    .pauseFor(2500)
    .deleteAll()
    .typeString('🏃 6.0 mi Morning Run')
    .pauseFor(2500)
    .deleteAll()
    .typeString('Morning Activity')
    .pauseFor(2500)
    .deleteAll()
    .typeString('🧘 1h 04m Yoga')
    .pauseFor(2500)
    .start();
});
