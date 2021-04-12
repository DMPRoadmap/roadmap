import { initAutocomplete, scrubOrgSelectionParamsOnSubmit } from '../../utils/autoComplete';

$(() => {
  if ($('#api-client-org-controls').length > 0) {
    initAutocomplete('#api-client-org-controls .autocomplete');
    scrubOrgSelectionParamsOnSubmit('form.api_client');
    scrubOrgSelectionParamsOnSubmit('#new_api_client');

    // Toggle the visibility of the Scopes sections based on the status of the 'Trusted' checkbox
    const toggleScopesBlocks = (context) => {
      const scopesBlocks = $('.oauth-scopes');

console.log(scopesBlocks);

      if (scopesBlocks.length > 0) {
        scopesBlocks.each((_idx, el) => {
          // If the API Client is 'trusted' then hide the Scopes and check them all
          if (context.prop('checked')) {
            $(el).addClass('hidden');
            $(el).find('input[type="checkbox"]').prop('checked', true);
          } else {
            $(el).removeClass('hidden');

            const authCheckbox = $('input#api_client_scopes_authorize_users');
            if (authCheckbox.length > 0) {
              toggleUserAuthorizationScopes(authCheckbox);
            }
          }
        });
      }
    };

    // Toggle the scopes that require a OAuthCredentialToken
    const toggleUserAuthorizationScopes = (context) => {
      const scopesBlock = $('.authorized-user-scopes');

      if (scopesBlock.length > 0) {
        if (context.prop('checked')) {
          scopesBlock.removeClass('hidden');
        } else {
          scopesBlock.addClass('hidden');
          scopesBlock.find('input[type="checkbox"]').prop('checked', false);
        }
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

    // If the 'authorize_users' scope is checked display the scopes that require User auth
    const authCheckbox = $('input#api_client_scopes_authorize_users');
    authCheckbox.on('click', () => {
      toggleUserAuthorizationScopes(authCheckbox);
    });
  }
});
