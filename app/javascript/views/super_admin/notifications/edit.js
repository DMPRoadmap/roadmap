import { Tinymce } from '../../../utils/tinymce.js';

$(() => {
  Tinymce.init({ selector: '.notification-text', forced_root_block: '' });
});
