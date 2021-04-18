import { initAutocomplete, scrubOrgSelectionParamsOnSubmit } from '../../utils/autoComplete';

$(() => {
  if ($('#api-client-org-controls').length > 0) {
    initAutocomplete('#api-client-org-controls .autocomplete');
    scrubOrgSelectionParamsOnSubmit('form.api_client');
    scrubOrgSelectionParamsOnSubmit('#new_api_client');

    // Toggle the visibility of the Scopes sections based on the status of the 'Trusted' checkbox
    const toggleScopesBlocks = (context) => {
      const scopesBlocks = $('.oauth-scopes');

      if (scopesBlocks.length > 0) {
        scopesBlocks.each((_idx, el) => {
          // If the API Client is 'trusted' then hide the Scopes and check them all
          if (context.prop('checked')) {
            $(el).addClass('hidden');
            $(el).find('input[type="checkbox"]').prop('checked', true);
          } else {
            $(el).removeClass('hidden');
          }
        });
      }
    };

    // If the 'trusted' checkbox is checked then hide the scopes blocks and auto-check all scopes
    const trusted = $('#api_client_trusted');
    if (trusted.length > 0) {
      toggleScopesBlocks(trusted);

      trusted.on('click', (e) => {
        toggleScopesBlocks($(e.target));
      });
    }
  }
});
