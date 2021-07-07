// Navigation Menu Toggle

$(() => {
  const menuHide = (button, menu) => {
    menu.attr('hidden', true);
    button.attr('aria-expanded', false);
  };

  const menuShow = (button, menu) => {
    menu.attr('hidden', false);
    button.attr('aria-expanded', true);
  };

  const menuToggle = (button, menu) => {
    if (button && menu) {
      if (menu.attr('hidden') === 'hidden') {
        menuShow(button, menu);
      } else {
        menuHide(button, menu);
      }
    }
  };

  const langMenu = $('#js-language');
  if (langMenu) {
    const langMenuToggle = $('#js-language__button');
    const langMenuGroup = $('#js-language__menu');

    langMenu.on('click', () => {
      menuToggle(langMenuToggle, langMenuGroup);
    });
    menuHide(langMenuToggle, langMenuGroup);
  }

  const profileMenu = $('#js-user-profile');
  if (profileMenu) {
    const profileMenuToggle = $('#js-user-profile__button');
    const profileMenuGroup = $('#js-user-profile__menu');

    profileMenu.on('click', () => {
      menuToggle(profileMenuToggle, profileMenuGroup);
    });
    menuHide(profileMenuToggle, profileMenuGroup);
  }
});
