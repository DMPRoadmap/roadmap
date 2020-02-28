import { Tinymce } from '../../../utils/tinymce.js.erb';

$(() => {
  Tinymce.init({ selector: '.notification-text', forced_root_block: '' });
});
