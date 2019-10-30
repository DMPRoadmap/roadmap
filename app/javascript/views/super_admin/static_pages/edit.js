import { Tinymce } from '../../../utils/tinymce';
import 'tinymce/plugins/code';
import 'tinymce/plugins/textcolor';
import 'tinymce/plugins/colorpicker';

$(() => {
  Tinymce.init({
    selector: '.content-editor',
    forced_root_block: '',
    toolbar: 'bold italic underline | formatselect fontsizeselect forecolor backcolor | bullist numlist | link | code',
    plugins: 'table autoresize link paste advlist lists code textcolor colorpicker',
    menubar: 'toolbar',
  });
});
