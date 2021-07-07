// Call To Action Component //

// Set the second CTA grid column to width of login component if CSS subgrid not supported:

$(() => {
  const calltoactionComp = document.querySelector('#js-calltoaction');

  if (calltoactionComp) {
    const loginComp = document.querySelector('#js-login');
    const loginCompStyle = window.getComputedStyle(loginComp);
    const loginCompWidth = parseInt(loginCompStyle.width, 10) + parseInt(loginCompStyle.margin, 10);

    if (!window.CSS.supports('grid-template-columns: subgrid')) {
      calltoactionComp.style.setProperty('--calltoaction-grid-columns', `auto ${loginCompWidth}px`);
    }
  }
});
