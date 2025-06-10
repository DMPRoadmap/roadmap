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
      $('#download-settings').hide();
    } else {
      $('#download-settings').show();
    }

    if (frmt === 'csv') {
      if ($('#phase_id option').length > 1) {
        $('#phase_id').find('option[value="All"').hide();
        $('#phase_id').val($('#phase_id option:eq(1)').val());
        $('#phase_id option:eq(1)').attr('selected', 'selected');
      }
    } else if (frmt === 'pdf' || frmt === 'html' || frmt === 'docx' || frmt === 'text') {
      if ($('#phase_id option').length > 1) {
        $('#phase_id').find('option[value="All"').show();
        $('#phase_id').val($('#phase_id option:first').val());
        $('#phase_id option:first').attr('selected', 'selected');
      }
    }
  }).trigger('change');

  // --- Start of format and phase validation code ---
  const downloadForm = document.getElementById('download_form');
  const formatSelect = document.getElementById('download_format_select');
  const phaseSelect = document.getElementById('phase_id'); // This might be null if phase_options.length <= 1
  const flashNoticeDiv = document.getElementById('client-side-flash-notice');
  const downloadButton = downloadForm.querySelector('button[type="submit"]');

  if (downloadForm && formatSelect && flashNoticeDiv && downloadButton) {
    downloadForm.addEventListener('submit', function(event) {
      let errorMessage = "";
      let isFormatValid = true;
      let isPhaseValid = true; // Assume valid initially, or if phaseSelect doesn't exist

      const selectedFormat = formatSelect.value;
      const selectedPhase = phaseSelect ? phaseSelect.value : "N/A"; // Use "N/A" or similar if no phase select, to distinguish from actual ""

      // Check if Format is selected
      if (selectedFormat === "") {
        isFormatValid = false;
      }

      // Check if Phase is selected (only if phaseSelect exists)
      if (phaseSelect && selectedPhase === "") {
        isPhaseValid = false;
      }

      // Construct the error message based on validity flags
      if (!isFormatValid && !isPhaseValid) {
        errorMessage = "Please select a format and a phase before downloading the plan.";
      } else if (!isFormatValid) {
        errorMessage = "Please select a format before downloading the plan.";
      } else if (!isPhaseValid) { // This implies phaseSelect exists and format is valid
        errorMessage = "Please select a phase to download.";
      }

      // Apply/Remove is-invalid class based on individual validity
      if (isFormatValid) {
        formatSelect.classList.remove('is-invalid');
      } else {
        formatSelect.classList.add('is-invalid');
      }

      if (phaseSelect) { // Only apply if phaseSelect actually exists on the page
        if (isPhaseValid) {
          phaseSelect.classList.remove('is-invalid');
        } else {
          phaseSelect.classList.add('is-invalid');
        }
      }

      if (errorMessage !== "") {
        // Prevent the form from submitting if there's any error
        event.preventDefault();

        // Display the flash notice
        flashNoticeDiv.textContent = errorMessage;
        flashNoticeDiv.style.display = 'block'; // Make it visible

        // Optional: Scroll to the top to make sure the message is visible
        window.scrollTo({ top: 0, behavior: 'smooth' });

      } else {
        // All valid, allow the form to submit
        // Hide any previously shown validation message
        flashNoticeDiv.style.display = 'none';
      }
    });

    // Optional: Clear validation message when user actually selects an option
    formatSelect.addEventListener('change', function() {
      // Re-evaluate validity based on current selections
      const currentFormatValid = (formatSelect.value !== "");
      const currentPhaseValid = (phaseSelect ? (phaseSelect.value !== "") : true); // If no phaseSelect, it's always valid

      // Hide main flash notice if both are now valid
      if (currentFormatValid && currentPhaseValid) {
        flashNoticeDiv.style.display = 'none';
      }
      // Always remove the specific field's invalid class if it's now valid
      if (currentFormatValid) {
        formatSelect.classList.remove('is-invalid');
      }
    });

     // Optional: Clear phase validation message when user selects a phase
     if (phaseSelect) { // Only add this if phaseSelect exists
        phaseSelect.addEventListener('change', function() {
          // Re-evaluate validity based on current selections
          const currentFormatValid = (formatSelect.value !== "");
          const currentPhaseValid = (phaseSelect.value !== "");

          // Hide main flash notice if both are now valid
          if (currentFormatValid && currentPhaseValid) {
            flashNoticeDiv.style.display = 'none';
          }
          // Always remove the specific field's invalid class if it's now valid
          if (currentPhaseValid) {
            phaseSelect.classList.remove('is-invalid');
          }
        });
      }
  }
  // --- End of format and phase validation code ---
});