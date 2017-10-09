import 'bootstrap-sass/assets/javascripts/bootstrap/collapse';
import expandCollapseAll from '../../utils/expandCollapseAll';

$(() => {
  // Attach handlers for the expand/collapse all accordions
  expandCollapseAll();
  $('.phase_show_link').on('click', (e) => {
    e.preventDefault();
    $(e.target).closest('.phase_edit').hide();
    $(e.target).closest('.tab-pane').find('.phase_show').show();
  });
});
