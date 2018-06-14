import ariatiseForm from '../../../utils/ariatiseForm';
import { Tinymce } from '../../../utils/tinymce';

$(() => {
  Tinymce.init({
    selector: '.notification-text',
    forced_root_block: '',
    toolbar: 'bold italic underline | link',
  });
  ariatiseForm({ selector: 'form.notification' });
});
