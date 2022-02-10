$(() => {
  // Add a target="_blank" to the form when PDF or HTML are selected
  // Hide the PDF Formatting section if 'pdf' is not the desired format
  $('#download_form select#format').on('change', (e) => {
    const frmt = $(e.currentTarget).val();

    if (frmt === 'pdf' || frmt === 'html' || frmt === 'json') {
      $('#download_form').attr('target', '_blank');
    } else {
      $('#download_form').removeAttr('target');
    }

    if (frmt === 'pdf') {
      $('#pdf-formatting').show();
    } else {
      $('#pdf-formatting').hide();
    }

    if ($(e.currentTarget).val() === 'json') {
      $('#research-output-export-mode, #export-options').hide();
      $('#json-formatting').show();
      $('#download-settings').hide();
    } else {
      $('#research-output-export-mode, #export-options').show();
      $('#json-formatting').hide();
      $('#download-settings').show();
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
