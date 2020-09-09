import { initAutocomplete } from '../../../utils/autoComplete';

$(() => {
  if ($('#api-client-org-controls').length > 0) {
    initAutocomplete('#api-client-org-controls .autocomplete');
  }
});
