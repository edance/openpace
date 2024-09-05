// Load fonts async
import Iconify from "@iconify/iconify";

// Iconify must scan the dom each load and replace the icons
// Enable caching in localStorage
Iconify.enableCache("local");

window.addEventListener("phx:page-loading-stop", Iconify.scan);
window.addEventListener("load", Iconify.scan);
