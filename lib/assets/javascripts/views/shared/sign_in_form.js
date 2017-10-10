import ariatiseForm from '../../utils/ariatiseForm';
import { togglisePasswords } from '../../utils/passwordHelper';

$(() => {
  ariatiseForm({ selector: '#sign_in_form' });
  togglisePasswords({ selector: '#sign_in_form' });
});
