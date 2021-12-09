
import AutoNumeric from 'autonumeric';
import { Tinymce } from './tinymce.js.erb';
import { Select2 } from './select2';

const toolbar = 'bold italic underline | fontsizeselect forecolor | bullist numlist | link | table';

export const formLoadingCallback = (data, target, source) => {
  if (source === 'plan_details') {
    Tinymce.init({
      toolbar,
    });
    Select2.init('.plan-details');
    // eslint-disable-next-line no-new
    new AutoNumeric(
      '.plan-details .number-field',
      { digitGroupSeparator: ' ', decimalPlaces: '0' },
    );
  } else if (source === 'modal_form') {
    Tinymce.init({
      toolbar,
    });
    Select2.init('#modal-window');
    // eslint-disable-next-line no-new
    new AutoNumeric(
      '#modal-window .number-field',
      { digitGroupSeparator: ' ', decimalPlaces: '0' },
    );
  } else {
    Tinymce.init({
      selector: `#research_output_${data.research_output.id}_section_${data.section.id} .note`,
      toolbar,
    });
    Select2.init(`#answer-form-${data.question.id}-research-output-${data.research_output.id}`);
    target.find('.toggle-guidance-section').removeClass('disabled');
    // eslint-disable-next-line no-new
    new AutoNumeric(
      `#answer-form-${data.question.id}-research-output-${data.research_output.id} .number-field`,
      { digitGroupSeparator: ' ', decimalPlaces: '0' },
    );
  }
  $('[data-toggle="tooltip"]:not([data-placement])').tooltip({
    animated: 'fade',
    placement: 'bottom',
  });
};

export default formLoadingCallback;
