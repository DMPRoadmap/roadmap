import { Tinymce } from '../../utils/tinymce';
import 'tinymce/plugins/code';

$(() => {
  Tinymce.init({
    selector: '.content-editor',
    toolbar: 'bold italic underline | formatselect fontsizeselect forecolor backcolor | bullist numlist | link | code',
    plugins: 'table autoresize link advlist lists code',
  });
});
