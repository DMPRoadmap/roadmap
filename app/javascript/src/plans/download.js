$(() => {
  // Add a target="_blank" to the form when PDF or HTML are selected
  // Hide the PDF Formatting section if 'pdf' is not the desired format
  $('#download_form select#format').change((e) => {
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
      $('#download-settings').hide();
    } else {
      $('#download-settings').show();
    }

    /*
     Issue 70: first option 'All Phases' should be selected in default for pdf, html, docx and text.
     Skip json for now since no phase has been set up yet for this format
     For csv:
     - Muti-phase download not allowed for csv
     - the second phase will be automatically selected and 'All Phases' option will be hidden
     */
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
});
