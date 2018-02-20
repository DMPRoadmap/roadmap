// Globally ensure that any URLs that are directing the user offsite open in a new tab/window
$(() => {
  $('a[href^="http"]').click((e) => {
    const link = $(e.target);
    const regex = /^https?:\/\.dmptool/i;
    const exceptions = {
      ids: ['connect-orcid-button'],
    };
    if (
      !link.attr('target') &&
      !regex.test(link.attr('href')) &&
      !exceptions.ids.indexOf(link.attr('id')) >= 0
    ) {
      link.attr('target', '_blank');
    }
  });
});
