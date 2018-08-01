import { Tinymce } from '../../../utils/tinymce';
import * as Validator from '../../../utils/validator';
import { eachLinks } from '../../../utils/links';

$(() => {
  Tinymce.init({ selector: '.template' });
  Validator.enableValidations({ selector: '.new_template' });

  $('.new_template').on('submit', () => {
    const links = {};
    eachLinks((ctx, value) => {
      links[ctx] = value;
    }).done(() => {
      $('#template-links').val(JSON.stringify(links));
    });
    // if (!validate(e.target)) {
    //   e.preventDefault();
    // }
  });
});
