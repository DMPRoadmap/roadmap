import { initAutocomplete, scrubOrgSelectionParamsOnSubmit } from '../../utils/autoComplete';

$(() => {
  if ($('#api-client-org-controls').length > 0) {
    initAutocomplete('#api-client-org-controls .autocomplete');
    scrubOrgSelectionParamsOnSubmit('form.api_client');
    scrubOrgSelectionParamsOnSubmit('#new_api_client');
  }
});
