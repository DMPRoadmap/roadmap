
import { Tinymce } from './tinymce.js.erb';
import { Select2 } from './select2';

const toolbar = 'bold italic underline | fontsizeselect forecolor | bullist numlist | link | table';

export const formLoadingCallback = (data, target, source) => {
  if (source === 'plan_details') {
    Tinymce.init({
      toolbar,
    });
    Select2.init('.plan-details');
  } else {
    Tinymce.init({
      selector: `#research_output_${data.research_output.id}_section_${data.section.id} .note`,
      toolbar,
    });
    Select2.init(`#answer-form-${data.question.id}-research-output-${data.research_output.id}`);
    target.find('.toggle-guidance-section').removeClass('disabled');
  }
  $('[data-toggle="tooltip"]:not([data-placement])').tooltip({
    animated: 'fade',
    placement: 'bottom',
  });
};

export default formLoadingCallback;
