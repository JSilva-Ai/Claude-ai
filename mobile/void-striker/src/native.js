/**
 * The native shim.
 *
 * This file is the entire difference between the game running in a browser tab
 * and the game running as an installed app. It is loaded before the game's own
 * script and it never reaches into the game: VOID STRIKER is one self-contained
 * HTML file with an IIFE around it and no exported state, and it stays that way
 * so that a new build of the game drops in with `npm run sync` and nothing else.
 *
 * Everything here is therefore done from the outside — by wrapping a browser
 * constructor, or by reading the DOM the game already renders.
 *
 * On a plain web page none of this runs: without the Capacitor bridge the file
 * returns immediately, so the same www/ can still be opened in a browser to
 * check a build.
 */
(function () {
  'use strict';

  /**
   * Track every AudioContext the game creates.
   *
   * The game builds its music out of live oscillators rather than a streamed
   * file, so there is no `pause()` to call from out here. Suspending the
   * context is the equivalent, and it is the only handle on the audio that
   * exists without editing the game.
   *
   * iOS suspends the context on its own when an app is backgrounded; Android's
   * WebView does not reliably, which is how you end up with a phone in a pocket
   * still playing the title theme.
   */
  var contexts = [];
  function track(Base) {
    if (typeof Base !== 'function') return Base;
    function Tracked() {
      var ac = new Base(arguments[0]);
      contexts.push(ac);
      return ac;
    }
    Tracked.prototype = Base.prototype;
    return Tracked;
  }
  window.AudioContext = track(window.AudioContext);
  window.webkitAudioContext = track(window.webkitAudioContext);

  function audio(state) {
    contexts.forEach(function (ac) {
      try {
        if (state === 'suspend' && ac.state === 'running') ac.suspend();
        if (state === 'resume' && ac.state === 'suspended') ac.resume();
      } catch {
        /* A context the game already closed. Nothing to do. */
      }
    });
  }

  var cap = window.Capacitor;
  if (!cap || !cap.isNativePlatform || !cap.isNativePlatform()) return;

  var App = cap.Plugins && cap.Plugins.App;
  if (!App) return;

  App.addListener('appStateChange', function (state) {
    audio(state.isActive ? 'resume' : 'suspend');
  });

  /**
   * Android's hardware/gesture back.
   *
   * Without a listener Capacitor's default is to exit the app, and that is the
   * wrong answer here twice over. A modal is open more often than not — the
   * main menu, the leaderboard, the achievements list all live in one — and
   * back should close it. And mid-run there is nowhere to go back to: the game
   * has no pause and no save, so exiting would silently destroy the run.
   * Minimising leaves the process alive, which is what the OS's own
   * back-out-of-a-game behaviour looks like, and the launcher still lets you
   * close it properly.
   */
  App.addListener('backButton', function () {
    var modal = document.getElementById('modal');
    var close = document.getElementById('modal-close');
    /*
     * `closeable: false` is a decision the game makes per screen — the main
     * menu is one — and it expresses it by hiding the close button. Back
     * honours that rather than overriding it, and falls through to minimising.
     *
     * popModal is called rather than clicking the button because the game
     * happens to expose it on `window` (it drives the modals' inline onclick
     * attributes), and because the button has two click listeners bound to it,
     * so a synthetic click pops two levels instead of one.
     */
    if (modal && modal.classList.contains('open') && close && close.style.display !== 'none') {
      if (typeof window.popModal === 'function') {
        window.popModal();
        return;
      }
    }
    if (App.minimizeApp) App.minimizeApp();
    else App.exitApp();
  });
})();
