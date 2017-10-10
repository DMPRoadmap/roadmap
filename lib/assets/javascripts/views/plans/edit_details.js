import { Tinymce } from '../../utils/tinymce';
import ariatiseForm from '../../utils/ariatiseForm';

$(() => {
  Tinymce.init();
  $('#is_test').click(() => {
    $('#plan_visibility').val($(this).is(':checked') ? 'is_test' : 'privately_visible');
  });
  ariatiseForm({ selector: '.edit_plan' });
});
