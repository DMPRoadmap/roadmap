import 'bootstrap-sass/assets/javascripts/bootstrap/collapse';
import expandCollapseAll from '../../../utils/expandCollapseAll';
import { Tinymce } from '../../../utils/tinymce';
import ariatiseForm from '../../../utils/ariatiseForm';

$(() => {
  // Attach handlers for the expand/collapse all accordions
  expandCollapseAll();
  Tinymce.init({ selector: '.phase' });
  ariatiseForm({ selector: '.phase_form' });
  const parentSelector = '#sections_accordion';
  $(parentSelector).on('ajax:before', (e) => {
    const panelBody = $(e.target).parent().find('.panel-body');
    return panelBody.attr('data-loaded') === 'false';
  });
  $(parentSelector).on('ajax:success', 'a[data-remote="true"]', (e, data) => {
    const panelBody = $(e.target).parent().find('.panel-body');
    panelBody.attr('data-loaded', 'true');
    panelBody.html(data);
    Tinymce.init({ selector: '.section, .question' });
    ariatiseForm({ selector: '.section_form, .question_form' });
  });
  $(parentSelector).on('ajax:error', 'a[data-remote="true"]', () => {
    // TODO something generic for every error
  });
});
