import * as Validator from '../../utils/validator';
import { Tinymce } from '../../utils/tinymce';

$(() => {
  Tinymce.init({ selector: '#guidance-text' });
  Validator.enableValidations({ selector: '#new_edit_guidance' });
});
