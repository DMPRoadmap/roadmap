import * as Validator from '../../../utils/validator';
import { Tinymce } from '../../../utils/tinymce';

$(() => {
  Tinymce.init({ selector: '#theme_description' });
  Validator.enableValidations({ selector: 'form.theme' });
});
