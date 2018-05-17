import 'bootstrap-sass/assets/javascripts/bootstrap/collapse';
import expandCollapseAll from '../../../utils/expandCollapseAll';
import getConstant from '../../../constants';
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
    const panel = panelBody.parent();
    if (isObject(panelBody)) {
      // Display the section's html
      panelBody.attr('data-loaded', 'true');
      panelBody.html(data);
      // Wire up the section
      initSection(panel.attr('id'));
    }
  });
  $(parentSelector).on('ajax:error', 'a[data-remote="true"]', (e) => {
    const panelBody = $(e.target).parent().find('.panel-body');
    panelBody.html(`<div class="pull-right alert alert-warning" role="alert">${getConstant('AJAX_UNABLE_TO_LOAD_TEMPLATE_SECTION')}</div>`);
  });
  // Wire up the currently displayed section (if there is one and the new section form)
  const selectedPanel = $('[role="tabpanel"].in');
  if (isObject(selectedPanel)) {
    initSection(selectedPanel.attr('id'));
  }
});
