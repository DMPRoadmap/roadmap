$(() => {
  $('.copy-link').click((e) => {
    const link = $(e.currentTarget).siblings('.direct-link');

    $('#link-modal').on('show.bs.modal', () => {
      $('#link').val(link.attr('href'));
    });
  });

  $('#copy-link-btn').click(() => {
    $('#link').select();
    // eslint-disable-next-line
    document.execCommand('copy');
  });
});
