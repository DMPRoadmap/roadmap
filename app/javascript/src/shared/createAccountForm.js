import { initAutocomplete, scrubOrgSelectionParamsOnSubmit } from '../utils/autoComplete';
import { togglisePasswords } from '../utils/passwordHelper';

$(() => {
  initAutocomplete('#create-account-org-controls .autocomplete');
  // Scrub out the large arrays of data used for the Org Selector JS so that they
  // are not a part of the form submissiomn
  scrubOrgSelectionParamsOnSubmit('#create_account_form');
  togglisePasswords({ selector: '#create_account_form' });
});
