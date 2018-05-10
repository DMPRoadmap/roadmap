import 'bootstrap-sass/assets/javascripts/bootstrap/collapse';
import expandCollapseAll from '../../../utils/expandCollapseAll';
import { Tinymce } from '../../../utils/tinymce';
import { isObject } from '../../../utils/isType';
import ariatiseForm from '../../../utils/ariatiseForm';
import initSection from '../sections/new_edit';

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
    if (isObject(panelBody)) {
      const id = panelBody.closest('.collapse').attr('id');
      // Display the section's html
      panelBody.attr('data-loaded', 'true');
      panelBody.html(data);
      // Wire up the section
      initSection(id);
    }
  });
  $(parentSelector).on('ajax:error', 'a[data-remote="true"]', () => {
    // TODO something generic for every error
  });
  // Wire up the currently displayed section (if there is one)
  const selectedPanel = $('[role="tabpanel"].in');
  if (isObject(selectedPanel)) {
    initSection(selectedPanel.attr('id'));
  }
});
