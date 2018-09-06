import ariatiseForm from '../../utils/ariatiseForm';
import { Tinymce } from '../../utils/tinymce';

$(() => {
  Tinymce.init({ selector: '#guidance-text' });
  ariatiseForm({ selector: '#new_edit_guidance' });
});
