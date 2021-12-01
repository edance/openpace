// Load fonts async
import WebFont from 'webfontloader';
import Iconify from '@iconify/iconify';

WebFont.load({
  google: {
    families: ['Open Sans'],
  },
});

// Iconify must scan the dom each load and replace the icons
// Enable caching in localStorage
Iconify.enableCache('local');

window.addEventListener("phx:page-loading-stop", Iconify.scan);
window.addEventListener("load", Iconify.scan);
