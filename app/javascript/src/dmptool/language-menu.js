// Language Menu Toggle

const langMenu = document.querySelector('#js-language');
const langMenuToggle = document.querySelector('#js-language__button');
const langMenuGroup = document.querySelector('#js-language__menu');

const langMenuClose = () => {
  langMenuGroup.hidden = true;
  langMenuToggle.setAttribute('aria-expanded', false);
}

const langMenuTarget = event => {
  if (!langMenu.contains(event.target)) {
    langMenuClose();
  }
}

if (document.querySelector('#js-language')) {
  langMenuToggle.addEventListener('click', () => {
    if (langMenuGroup.hidden === true) {
      langMenuGroup.hidden = false;
      langMenuToggle.setAttribute('aria-expanded', true);
    } else {
      langMenuClose();
    }
  })

  // Clicking outside of menu closes it:
  window.addEventListener('click', langMenuTarget);

  // Tabbing outside of menu closes it:
  window.addEventListener('focusin', langMenuTarget);
}
