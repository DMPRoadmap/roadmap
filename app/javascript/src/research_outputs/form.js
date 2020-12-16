import { isUndefined, isObject } from '../utils/isType';
import { Tinymce } from '../utils/tinymce.js.erb';

$(() => {
  const form = $('.research_output_form');

  const toggleOutputTypeDescription = (otherSelected) => {
    const description = form.find('#research_output_output_type_description');
    const row = form.find('.output-type-description');

    if (!isUndefined(description) && isObject(description)) {
      if (otherSelected) {
        row.removeClass('hidden');
        description.attr('aria-required', 'true');
      } else {
        description.attr('aria-required', 'false');
        row.addClass('hidden');
      }
    }
  };

  const selectOutputType = (selection) => {
    toggleOutputTypeDescription(selection.val() === 'Other');
  };

  if (!isUndefined(form) && isObject(form)) {
    const outputTypeSelector = form.find('#research_output_output_type');

    if (!isUndefined(outputTypeSelector) && isObject(outputTypeSelector)) {
      // outputTypeSelector.on('change', (e) => { selectOutputType($(e.target).find('option:selected')); });

      // toggleOutputTypeDescription(outputTypeSelector.val() === 'Other');
    }

    Tinymce.init({ selector: "#research_output_description" });
  }
});
