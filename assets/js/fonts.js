// Load fonts async
import WebFont from 'webfontloader';
import Iconify from '@iconify/iconify';

WebFont.load({
  google: {
    families: ['Open Sans'],
  },
});

// Iconify must scan the dom each turbolinks load and replace the icons
// Enable caching in localStorage
Iconify.enableCache('local');
document.addEventListener("turbolinks:load", function() {
  Iconify.scan();
});
