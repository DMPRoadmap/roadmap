import { isUndefined, isObject } from '../utils/isType';
import { Tinymce } from '../utils/tinymce.js.erb';

$(() => {
  const form = $('.research_output_form');

  if (!isUndefined(form) && isObject(form)) {
    Tinymce.init({ selector: "#research_output_description" });
    Tinymce.init({ selector: "#research_output_mandatory_attribution" });
  }
});
