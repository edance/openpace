// Import dependencies
import "phoenix_html";

// Import bootstrap and required libraries
import "./bootstrap";

// Import base components
import "./components/base";

// Fonts
import "./fonts";

// Live View
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";

// Import all of the dashboard hooks
import hooks from "./hooks/dashboard";

const csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
const liveSocket = new LiveSocket("/live", Socket, {
  hooks,
  params: { _csrf_token: csrfToken },
});

// Connect if there are any LiveViews on the page
liveSocket.connect();

// Expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
// The latency simulator is enabled for the duration of the browser session.
// Call disableLatencySim() to disable:
// >> liveSocket.disableLatencySim()
liveSocket.enableDebug();

window.liveSocket = liveSocket;
