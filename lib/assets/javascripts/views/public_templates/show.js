$(() => {
  $('#maincontent').on('click', 'a.copy-link', (e) => {
    const link = $(e.currentTarget).siblings('.direct-link');

    $('#link-modal').on('show.bs.modal', () => {
      $('#link').val(link.attr('href'));
    });
  });

  $('#maincontent').on('click', '#copy-link-btn', () => {
    $('#link').select();
    // eslint-disable-next-line
    document.execCommand('copy');
  });
});
