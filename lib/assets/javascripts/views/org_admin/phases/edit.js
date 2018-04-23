import 'bootstrap-sass/assets/javascripts/bootstrap/collapse';
import expandCollapseAll from '../../../utils/expandCollapseAll';
import { Tinymce } from '../../../utils/tinymce';

$(() => {
  // Attach handlers for the expand/collapse all accordions
  expandCollapseAll();
  Tinymce.init({ selector: '.phase' });
});
