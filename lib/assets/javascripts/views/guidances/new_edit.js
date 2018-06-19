import ariatiseForm from '../../utils/ariatiseForm';
import { Tinymce } from '../../utils/tinymce';

$(() => {
  ariatiseForm({ selector: '#new_edit_guidance' });
  Tinymce.init({ selector: '#guidance-text' });
});
