import { initAutocomplete } from '../../utils/autoComplete';
import { togglisePasswords } from '../../utils/passwordHelper';

$(() => {
  const options = { selector: '#create_account_form' };
  initAutocomplete('#create-account-org-controls .autocomplete');
  togglisePasswords(options);
});
