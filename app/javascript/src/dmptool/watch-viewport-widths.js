// Viewport Width Media Queries //

import { headerNavOpen, headerNavClosed } from './navtoggle';
import { minwidth1 } from './breakpoints';

$(() => {
  const watchViewportWidth = (viewportWidth) => {
    if (viewportWidth.matches) {
      headerNavOpen();
    } else {
      headerNavClosed();
    }
  };

  const viewportWidth = window.matchMedia(`(min-width: ${minwidth1})`);

  // Listen on watchViewportWidth function for changes to viewportWidth:
  watchViewportWidth(viewportWidth);
  viewportWidth.addListener(watchViewportWidth);
});
