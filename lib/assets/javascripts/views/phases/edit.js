import 'bootstrap-sass/assets/javascripts/bootstrap/collapse';
import expandCollapseAll from '../../utils/expandCollapseAll';
import { Tinymce } from '../../utils/tinymce';

$(() => {
  // Attach handlers for the expand/collapse all accordions
  expandCollapseAll();
  Tinymce.init({ selector: '.phase' });
  $('.phase_show_link').on('click', (e) => {
    e.preventDefault();
    $(e.target).closest('.phase_edit').hide();
    $(e.target).closest('.tab-pane').find('.phase_show').show();
  });
});
