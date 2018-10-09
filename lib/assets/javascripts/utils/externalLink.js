import getConstant from '../constants';

// Globally ensure that any URLs that are directing the user offsite open in a new tab/window
$(() => {
  $('body').click('a[href^="http"]', (e) => {
    const link = $(e.target);
    const regex = new RegExp(`^https?://${getConstant('HOST')}`); // /^https?:\/\./i;
    const exceptions = {
      ids: ['connect-orcid-button', 'view-all-templates'],
    };
    if (
      !link.attr('target') &&
      !regex.test(link.attr('href')) &&
      !(exceptions.ids.indexOf(link.attr('id')) >= 0)
    ) {
      link.attr('target', '_blank');
    }
  });
});
