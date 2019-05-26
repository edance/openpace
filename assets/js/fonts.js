// Load fonts async
import WebFont from 'webfontloader';

WebFont.load({
  google: {
    families: ['Open Sans'],
  },
});

// Iconify must scan the dom each turbolinks load and replace the icons
Iconify.setConfig('localStorage', true);
document.addEventListener("turbolinks:load", function() {
  Iconify.scanDOM();
});
