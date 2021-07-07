// Navigation Toggle Component //

const headerNavOpen = () => {
  const inHeader = document.querySelector('.c-header');
  if (inHeader) {
    const navToggleButton = document.querySelector('#js-navtoggle');
    const headerNav = document.querySelector('#js-headernav');
    headerNav.hidden = false;
    navToggleButton.setAttribute('aria-expanded', true);
  }
};

const headerNavClosed = () => {
  const inHeader = document.querySelector('.c-header');
  if (inHeader) {
    const navToggleButton = document.querySelector('#js-navtoggle');
    const headerNav = document.querySelector('#js-headernav');
    headerNav.hidden = true;
    navToggleButton.setAttribute('aria-expanded', false);
  }
};

$(() => {
  const inHeader = document.querySelector('.c-header');
  if (inHeader) {
    const headerNav = document.querySelector('#js-headernav');
    const navToggleButton = document.querySelector('#js-navtoggle');
    navToggleButton.addEventListener('click', () => {
      if (headerNav.hidden === true) {
        headerNavOpen();
      } else {
        headerNavClosed();
      }
    });
  }
});

export { headerNavOpen, headerNavClosed };
