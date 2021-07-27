// Viewport Width Media Queries //

import { headerNavOpen, headerNavClosed } from './navtoggle.js';
import { minwidth1 } from './breakpoints.js';

const watchViewportWidth = viewportWidth => {
  if (viewportWidth.matches) {
    headerNavOpen();
  } else {
    headerNavClosed();
  }
}

const viewportWidth = window.matchMedia(`(min-width: ${minwidth1})`);

// Listen on watchViewportWidth function for changes to viewportWidth:

watchViewportWidth(viewportWidth);
viewportWidth.addListener(watchViewportWidth);
