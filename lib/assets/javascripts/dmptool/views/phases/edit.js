$(() => {
  $('#plan-guidance-tab .panel-body p > a').each((i, el) => {
    const link = $(el);
    if (!link.attr('target')) {
      link.attr('target', '_blank');
    }
  });
});
