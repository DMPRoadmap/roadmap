import getConstant from './constants';

// Globally ensure that any URLs that are directing the user offsite open in a new tab/window
$(() => {
  $('body').click('a[href^="http"]', (e) => {
    const link = $(e.target);
    const protocol = new RegExp('^https?');
    const regex = new RegExp(`^https?://${getConstant('HOST')}`);
    const exceptions = {
      ids: ['connect-orcid-button', 'view-all-templates'],
    };
    // Internal links are typically just the path, but also check for other domains
    if (
      !link.attr('target')
      && protocol.test(link.attr('href'))
      && !regex.test(link.attr('href'))
      && !(exceptions.ids.indexOf(link.attr('id')) >= 0)
    ) {
      link.attr('target', '_blank');
      link.addClass('has-new-window-popup-info');
      // Add span as child of link.
      link.append($(`<span class="new-window-popup-info">${getConstant('OPENS_IN_A_NEW_WINDOW_TEXT')}</span>`));
    }
  });

  $('a[href^="http"]').each((index, value) => {
    const link = $(value);
    const protocol = new RegExp('^https?');
    const regex = new RegExp(`^https?://${getConstant('HOST')}`);
    const exceptions = {
      ids: ['connect-orcid-button', 'view-all-templates'],
    };
    // Internal links are typically just the path, but also check for other domains
    if (
      !link.attr('target')
      && protocol.test(link.attr('href'))
      && !regex.test(link.attr('href'))
      && !(exceptions.ids.indexOf(link.attr('id')) >= 0)
    ) {
      link.attr('target', '_blank');
      link.addClass('has-new-window-popup-info');
      // Add span as child of link.
      link.append($(`<span class="new-window-popup-info">${getConstant('OPENS_IN_A_NEW_WINDOW_TEXT')}</span>`));
    }
  });
});
