import 'bootstrap-sass/assets/javascripts/bootstrap/tooltip';
import 'bootstrap-sass/assets/javascripts/bootstrap/popover';
import { Tinymce } from '../../utils/tinymce';
import ariatiseForm from '../../utils/ariatiseForm';

$(() => {
  $('[data-toggle="tooltip"]').tooltip();
  $('[data-toggle="popover"]').popover();
  Tinymce.init();
  $('#is_test').click(() => {
    $('#plan_visibility').val($(this).is(':checked') ? 'is_test' : 'privately_visible');
  });
  ariatiseForm({ selector: '.edit_plan' });
});
