import { initAutocomplete, scrubOrgSelectionParamsOnSubmit } from '../../utils/autoComplete';

$(() => {
  initAutocomplete('#invite-org-controls .autocomplete');
  // Scrub out the large arrays of data used for the Org Selector JS so that they
  // are not a part of the form submissiomn
  scrubOrgSelectionParamsOnSubmit('#invitation_create_account_form');
});
