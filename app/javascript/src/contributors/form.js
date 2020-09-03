import { initAutocomplete, scrubOrgSelectionParamsOnSubmit } from '../utils/autoComplete';

$(() => {
  initAutocomplete('#contributor-org-controls .autocomplete');
  // Scrub out the large arrays of data used for the Org Selector JS so that they
  // are not a part of the form submissiomn
  scrubOrgSelectionParamsOnSubmit('#new_contributor');
  scrubOrgSelectionParamsOnSubmit('form.edit_contributor');
});
