// Load fonts async
import WebFont from 'webfontloader';

WebFont.load({
  custom: {
    families: ['simple-line-icons'],
    urls: ['//cdnjs.cloudflare.com/ajax/libs/simple-line-icons/2.4.1/css/simple-line-icons.css'],
  },
  google: {
    families: ['Open Sans'],
  },
});

// Iconify must scan the dom each turbolinks load and replace the icons
Iconify.setConfig('localStorage', true);
document.addEventListener("turbolinks:load", function() {
  Iconify.scanDOM();
});
