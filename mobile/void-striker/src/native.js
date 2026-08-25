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

  /**
   * Leaving the app pauses the run.
   *
   * A call, Control Centre, or a swipe to another app freezes the WebView's
   * animation frames but not the player's situation: they come back to a ship
   * exactly where they left it, mid-formation, usually with a bullet already on
   * top of it. The game has a pause screen now, so backgrounding uses it — the
   * run is waiting rather than half-lost, and coming back is a deliberate tap
   * on RESUME instead of an ambush.
   *
   * It deliberately does not auto-resume: returning to a game that is already
   * moving is the same ambush from the other side.
   */
  App.addListener('appStateChange', function (state) {
    audio(state.isActive ? 'resume' : 'suspend');
    if (!state.isActive && typeof window.pauseGame === 'function') {
      try {
        window.pauseGame();
      } catch {
        /* The game decides whether there is a run to pause; if it throws, the
           worst case is the old behaviour, so this must not break audio. */
      }
    }
  });

  /**
   * Android's hardware/gesture back.
   *
   * Without a listener Capacitor's default is to exit the app, which is the
   * wrong answer: a modal is open more often than not — the main menu, the
   * leaderboard, the achievements list and now the pause screen all live in one
   * — and back should close it.
   *
   * Back mid-run used to fall through to minimising the app, because the game
   * had no pause and no save and there was genuinely nowhere to go: exiting
   * would have destroyed the run silently. The game has a pause screen now, so
   * back opens it. That is both what the gesture means everywhere else and a
   * strictly safer answer than dropping the player out of a live run.
   *
   * Minimising remains the last resort, for the title screen and the menus that
   * decline to be closed.
   */
  App.addListener('backButton', function () {
    var modal = document.getElementById('modal');
    var close = document.getElementById('modal-close');
    /*
     * `closeable: false` is a decision the game makes per screen — the main
     * menu is one — and it expresses it by hiding the close button. Back
     * honours that rather than overriding it, and falls through.
     *
     * popModal is called rather than clicking the button because the game
     * exposes it on `window` (it drives the modals' inline onclick attributes),
     * and a synthetic click would depend on the game's own listeners. Popping
     * the pause screen is also what resumes the run, so this one call covers
     * both closing a menu and un-pausing.
     */
    if (modal && modal.classList.contains('open') && close && close.style.display !== 'none') {
      if (typeof window.popModal === 'function') {
        window.popModal();
        return;
      }
    }

    /* Mid-run, back pauses rather than leaving. pauseGame reports whether it
       had anything to pause, so this falls through cleanly on the title. */
    if (typeof window.pauseGame === 'function' && window.pauseGame()) return;

    if (App.minimizeApp) App.minimizeApp();
    else App.exitApp();
  });
})();
