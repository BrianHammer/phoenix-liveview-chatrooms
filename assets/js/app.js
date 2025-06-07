// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
//////////////////////////////////
// Hooks
//////////////////////////////////
let Hooks = {};

// Sends a message to the client when texting has started or stopped
// It will send an event at the start of a client, and ends when input ends
Hooks.TypingIndicator = {
  mounted() {
    this.TIME_DELAY = 2000; //milliseconds
    this.isTyping = false;
    this.lastDebouncedRoomId = null;

    // Call a "stopped typing" when an input occurs
    const form = this.el.closest("form");
    if (form) {
      form.addEventListener("submit", () => {
        this.isTyping = false;
        this.pushEventTo(this.el, "typing-changed", { is_typing: false });
      });
    }

    // Whenever text is input it will call a 'typing' event
    this.el.addEventListener("input", (e) => {
      // Get the current room
      const roomId = this.el.dataset.roomId;

      // Debounces isTyping
      // Automatically bypasses when the ID is the same
      if (!this.isTyping || roomId !== this.lastDebouncedRoomId) {
        this.lastDebouncedRoomId = roomId;
        this.isTyping = true;
        this.pushEventTo(this.el, "typing-changed", { is_typing: true });
        console.log("INPUT STARTED...");
      }

      // Remove any old timeouts and create a new timeout
      if (this.timeoutId) {
        clearTimeout(this.timeoutId);
      }

      this.timeoutId = setTimeout(() => {
        if (this.isTyping) {
          this.isTyping = false;
          console.log("INPUT STOPPED...");
          this.pushEventTo(this.el, "typing-changed", { is_typing: false });
        }
      }, this.TIME_DELAY);
    });
  },

  destroyed() {
    console.log("I HAVE BEEN DESTROYED!!");
    if (this.timeoutId) clearTimeout(this.timeoutId);

    if (this.isTyping) {
      this.isTyping = false;
      this.pushEventTo(this.el, "typing-changed", { is_typing: false });
      console.log("INPUT STOPPED...");
    }
  },
};

//////////////////////////////////
// socket
//////////////////////////////////
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
