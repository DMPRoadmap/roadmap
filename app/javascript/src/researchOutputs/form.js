import getConstant from '../utils/constants';
import { isUndefined, isObject } from '../utils/isType';

$(() => {
  const form = $('.research_output_form');

  if (!isUndefined(form) && isObject(form)) {
    Tinymce.init({ selector: '#research_output_description' });
  }

  // Preload the search results when then user opens a modal dialog
  $('button.modal-opener').on('click', () => {
    $("div.modal-body button[type='submit']").click();
  });

  // Expands/Collapses the search results 'More info'/'Less info' section
  $('body').on('click', '.modal-search-result .more-info a.more-info-link', (e) => {
    e.preventDefault();
    const link = $(e.target);

    if (link.length > 0) {
      const info = $(link).siblings('div.info');

      if (info.length > 0) {
        if (info.hasClass('hidden')) {
          info.removeClass('hidden');
          link.text(`${getConstant('LESS_INFO')}`);
        } else {
          info.addClass('hidden');
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

  // Auto select the 'OTHER' license from the license select list if the checkbox is checked
  $('#use_custom_license').on('click', (e) => {
    const checkbox = $(e.currentTarget);
    const selectbox = $('#research_output_license_id');
    const hiddenOption = $('#other_license_option');
    const otherOption = $('#research_output_license_id option[text="OTHER"]');

    if (checkbox.is(':checked')) {
      if (otherOption.length <= 0) {
        selectbox.append(hiddenOption);
      }
      otherOption.prop('selected', true);
    } else {
      otherOption.prop('selected', false);
    }
  });
});
