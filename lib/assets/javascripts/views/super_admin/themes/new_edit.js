import ariatiseForm from '../../../utils/ariatiseForm';
import { Tinymce } from '../../../utils/tinymce';

$(() => {
  ariatiseForm({ selector: 'form.theme' });
  Tinymce.init({ selector: '#theme_description' });
});
