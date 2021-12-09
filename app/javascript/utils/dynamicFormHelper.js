
import { Tinymce } from './tinymce.js.erb';
import { Select2 } from './select2';
import { AutoNumericHelper } from './autoNumericHelper';

const toolbar = 'bold italic underline | fontsizeselect forecolor | bullist numlist | link | table';

export const formLoadingCallback = (data, target, source) => {
  if (source === 'plan_details') {
    Tinymce.init({
      toolbar,
    });
    Select2.init('.plan-details');
    AutoNumericHelper.init('.plan-details .number-field');
  } else if (source === 'modal_form') {
    Tinymce.init({
      toolbar,
    });
    Select2.init('#modal-window');
    AutoNumericHelper.init('#modal-window .number-field');
  } else {
    Tinymce.init({
      selector: `#research_output_${data.research_output.id}_section_${data.section.id} .note`,
      toolbar,
    });
    Select2.init(`#answer-form-${data.question.id}-research-output-${data.research_output.id}`);
    target.find('.toggle-guidance-section').removeClass('disabled');
    AutoNumericHelper.init(`#answer-form-${data.question.id}-research-output-${data.research_output.id} .number-field`);
  }
  $('[data-toggle="tooltip"]:not([data-placement])').tooltip({
    animated: 'fade',
    placement: 'bottom',
  });
};

export default formLoadingCallback;
