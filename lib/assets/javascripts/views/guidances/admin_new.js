import ariatiseForm from '../../utils/ariatiseForm';
import { Tinymce } from '../../utils/tinymce';

$(() => {
  ariatiseForm({ selector: '#new_guidance_form' });
  Tinymce.init({ selector: '.tinymce' });
});
