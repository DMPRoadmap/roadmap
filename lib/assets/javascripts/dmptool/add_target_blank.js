$(() => {
  $('a[href^="http"]').click((e) => {
    const link = $(e.target);
    const regex = /^https?:\/\.dmptool/i;
    if (!link.attr('target') && !regex.test(link.attr('href'))) {
      link.attr('target', '_blank');
    }
  });
});
