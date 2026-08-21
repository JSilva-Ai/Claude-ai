import type { CapacitorConfig } from '@capacitor/cli';

/**
 * VOID STRIKER, as a native app.
 *
 * The game itself is unchanged: `www/` is generated from the same single HTML
 * file the website serves (see scripts/build-www.mjs). Nothing here reaches
 * back into the site's build — this is a separate npm project on purpose, so
 * `npm run build` at the repo root never pulls in the mobile toolchain.
 */
const config: CapacitorConfig = {
  /**
   * The bundle identifier, and the one value in this file that cannot be
   * changed later: it is the app's identity on both stores, and once a build
   * has been uploaded under it, it is permanent.
   *
   * Derived from the studio's domain rather than chosen — newaivisionlabs.com
   * reversed, plus the product. CONFIRM THIS BEFORE THE FIRST UPLOAD; after
   * that it is fixed forever.
   */
  appId: 'com.newaivisionlabs.voidstriker',

  /** What shows under the icon on the home screen. */
  appName: 'VOID STRIKER',

  webDir: 'www',

  /**
   * The game paints its own black background and letterboxes itself inside
   * whatever viewport it is given. The web view underneath must be black too,
   * or the letterbox flashes white on every launch and rotation.
   */
  backgroundColor: '#000000',

  android: {
    backgroundColor: '#000000',
    /**
     * The game is a canvas that fits itself to the viewport. Nothing on the
     * page scrolls, and an accidental over-scroll would drag the whole game
     * out from under the player's thumb.
     */
    webContentsDebuggingEnabled: false,
  },

  ios: {
    backgroundColor: '#000000',
    /** Same reason: no scroll view behaviour behind a fixed-size canvas. */
    scrollEnabled: false,
    contentInset: 'never',
  },
};

export default config;
