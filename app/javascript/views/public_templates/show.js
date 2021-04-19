$(() => {
  $(document).on('click', '.copy-link', (e) => {
    const sourceUrl = $(e.currentTarget).siblings('.direct-link')
      .attr('href');
    $('#link').val(sourceUrl);
  });

  $(document).on('click', '#copy-link-btn', () => {
    $('#link').trigger('select');
    // eslint-disable-next-line
    document.execCommand('copy');
  });
});
