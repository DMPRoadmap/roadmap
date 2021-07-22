import { initAutocomplete, scrubOrgSelectionParamsOnSubmit } from '../../utils/autoComplete';

$(() => {
  // Org selector on the /users/sign_up page that loads after a user
  // signs in via institutional credentials but has no matching user record
  initAutocomplete('#create-account-org-controls .autocomplete');
  // Scrub out the large arrays of data used for the Org Selector JS so that they
  // are not a part of the form submissiomn
  scrubOrgSelectionParamsOnSubmit('#create_account_form');
});
