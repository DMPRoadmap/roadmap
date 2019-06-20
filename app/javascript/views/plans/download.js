$(() => {
  // Add a target="_blank" to the form when PDF or HTML are selected
  // Hide the PDF Formatting section if 'pdf' is not the desired format
  $('#download_form select#format').on('change', (e) => {
    if ($(e.currentTarget).val() === 'pdf' || $(e.currentTarget).val() === 'html') {
      $('#download_form').attr('target', '_blank');
    } else {
      $('#download_form').removeAttr('target');
    }

    if ($(e.currentTarget).val() === 'pdf') {
      $('#pdf-formatting').show();
    } else {
      $('#pdf-formatting').hide();
    }
  });

  $('#select-all-phases').on('click', (e) => {
    if (e.target.checked) {
      // Iterate each checkbox
      $('.phase-checkbox').each(function check() {
        this.checked = true;
      });
    } else {
      $('.phase-checkbox').each(function check() {
        this.checked = false;
      });
    }
  });

  $('#select-all-research-outputs').on('click', (e) => {
    if (e.target.checked) {
      // Iterate each checkbox
      $('.research-output-checkbox').each(function check() {
        this.checked = true;
      });
    } else {
      $('.research-output-checkbox').each(function check() {
        this.checked = false;
      });
    }
  });
});
