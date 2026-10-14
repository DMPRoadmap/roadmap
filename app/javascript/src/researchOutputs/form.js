import getConstant from '../utils/constants';
import { isUndefined, isObject } from '../utils/isType';
import { Tinymce } from '../utils/tinymce.js';

const STATUS_CLASSES = 'd-none text-muted text-danger text-success';

$(() => {
  const form = $('.research_output_form');

  if (!isUndefined(form) && isObject(form)) {
    Tinymce.init({ selector: '#research_output_description' });
  }

  // Toggle DOI form visibility
  $('body').on('click', '#btn_toggle_doi_form', (e) => {
    e.preventDefault();
    const panel = $('#doi_lookup_panel');

    panel.toggleClass('d-none');
    
    if (!panel.hasClass('d-none')) {
      $('#doi_lookup_input').focus();
    }
  });

  // Resolve the DOI in the new form request to avoid a second provider lookup.
  $('body').on('click', '#btn_fetch_doi', (e) => {
    e.preventDefault();
    const button = $(e.currentTarget);
    const inputField = $('#doi_lookup_input');
    const statusText = $('#doi_lookup_status');
    
    const doi = inputField.val().trim();
    
    const newResearchOutputPath = button.data('new-research-output-path');

    // Helper for DRY-ing state updates
    const setLookupStatus = (type, message) => {
      statusText.removeClass(STATUS_CLASSES).addClass(type).text(message);
    };

    if (!doi) {
      setLookupStatus('text-danger', getConstant('DOI_VALIDATION_EMPTY'));
      return;
    }

    window.location.href = `${newResearchOutputPath}?prefill_doi=${encodeURIComponent(doi)}`;
  });


  // Expands/Collapses the search results 'More info'/'Less info' section
  $('body').on('click', '.modal-search-result .more-info a.more-info-link', (e) => {
    e.preventDefault();
    const link = $(e.target);

    if (link.length > 0) {
      const info = $(link).siblings('div.info');

      if (info.length > 0) {
        if (info.hasClass('d-none')) {
          info.removeClass('d-none');
          link.text(`${getConstant('LESS_INFO')}`);
        } else {
          info.addClass('d-none');
          link.text(`${getConstant('MORE_INFO')}`);
        }
      }
    }
  });

  // Put the facet text into the modal search window's search box when the user
  // clicks on one
  $('body').on('click', '.modal-search-result a.facet', (e) => {
    const link = $(e.target);

    if (link.length > 0) {
      const textField = link.closest('.modal-body').find('input.autocomplete');

      if (textField.length > 0) {
        textField.val(link.text());
      }
    }
  });
});
