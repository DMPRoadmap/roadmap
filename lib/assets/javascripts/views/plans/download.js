$(() => {
  // Hide the PDF Formatting section if 'pdf' is not the desired format
  $('select#format').on('change', (e) => {
    if ($(e.currentTarget).val() === 'pdf') {
      $('#pdf-formatting').show();
    } else {
      $('#pdf-formatting').hide();
    }
  });
});
