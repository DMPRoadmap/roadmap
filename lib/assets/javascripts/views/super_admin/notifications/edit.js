import * as Validator from '../../../utils/validator';
import { Tinymce } from '../../../utils/tinymce';

$(() => {
  Tinymce.init({ selector: '.notification-text', forced_root_block: '' });
  Validator.enableValidations({ selector: 'form.notification' });
});
