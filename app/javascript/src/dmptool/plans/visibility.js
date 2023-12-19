import toggleSpinner from '../../utils/spinner';

$(() => {
  const togglePlanVisibilityTerms = (termsBlock, isPublic) => {
    const termsCheckBox = termsBlock.find('#plan_accept_terms');

    // If Organisationally or privately visible was checked, then unaccept the terms
    if (!isPublic) {
      termsBlock.css("display", "none");
      termsCheckBox.removeClass("require-me");
      termsCheckBox.closest('.js-checkbox').removeClass("is-required");
    } else {
      termsBlock.css("display", "block");
      termsCheckBox.addClass("require-me");
      termsCheckBox.closest('.js-checkbox').addClass("is-required");
    }
  }

  const termsBlock = $('#visibility-terms');

  if (termsBlock !== undefined) {
    const privatelyVisibleRadio = $('#plan_visibility_privately_visible');
    const organisationallyVisibleRadio = $('#plan_visibility_organisationally_visible');
    const publiclyVisibleRadio = $('#plan_visibility_publicly_visible');
    const hiddenVisibility = $('#plan_visibility');
    const visibilityErrorMessage = $("#missing-accept-terms");

    // Hide the error message on page load
    if (hiddenVisibility.val() !== 'publicly_visible') {
      visibilityErrorMessage.css("display", "none")
    }

    // Add event handlers to visibility options
    publiclyVisibleRadio.on('change', () => {
      hiddenVisibility.val("publicly_visible");
      togglePlanVisibilityTerms(termsBlock, true);
    });
    organisationallyVisibleRadio.on('change', () => {
      hiddenVisibility.val("organisationally_visible");
      togglePlanVisibilityTerms(termsBlock, false);
    });
    privatelyVisibleRadio.on('change', () => {
      hiddenVisibility.val("privately_visible");
      togglePlanVisibilityTerms(termsBlock, false);
    });

    // Check the initial visibility on page load
    togglePlanVisibilityTerms(termsBlock, hiddenVisibility.val() === 'publicly_visible');

    // Verify that the user accepted the terms
    termsBlock.closest('form').on('submit', (e) => {
      if (hiddenVisibility.val() === 'publicly_visible' && !termsBlock.find('#plan_accept_terms').prop("checked")) {
        e.preventDefault();
        e.stopPropagation();
        toggleSpinner(false);
        visibilityErrorMessage.css("display", "block");

      } else {
        visibilityErrorMessage.css("display", "none");
      }
    });
  }
});
