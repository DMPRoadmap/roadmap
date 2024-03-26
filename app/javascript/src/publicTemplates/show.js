$(() => {
  $('body').on('click', '.copy-link', (e) => {
    const link = $(e.currentTarget).siblings('.direct-link');

    $('#link-modal').on('show.bs.modal', () => {
      $('#link').val(link.attr('href'));
    });
  });

  $('body').on('click', '#copy-link-btn', () => {
    navigator.clipboard.writeText($('#link').val());
  });
});
