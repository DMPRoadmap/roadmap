import { Tinymce } from '../../../utils/tinymce';

$(() => {
  Tinymce.init({ selector: '.notification-text', forced_root_block: '' });
});
