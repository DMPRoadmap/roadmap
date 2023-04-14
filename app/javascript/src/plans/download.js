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

    if (frmt === 'json') {
      $('#research-output-export-mode, #export-options').hide();
      $('#json-formatting').show();
      $('#download-settings').hide();
    } else {
      $('#research-output-export-mode, #export-options').show();
      $('#json-formatting').hide();
      $('#download-settings').show();
    }

    if (frmt === 'csv') {
      $('#phase_id').find('option[value="All"').hide();
      $('#phase_id option:eq(1)').attr('selected', 'selected');
      $('#phase_id').val($('#phase_id option:eq(1)').val());
    } else if (frmt === 'pdf' || frmt === 'html' || frmt === 'docx' || frmt === 'text') {
      $('#phase_id').find('option[value="All"').show();
      $('#phase_id').val($('#phase_id option:first').val());
      $('#phase_id option:first').attr('selected', 'selected');
    }
  }).trigger('change');

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
