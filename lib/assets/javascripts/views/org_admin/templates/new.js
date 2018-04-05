import { Tinymce } from '../../../utils/tinymce';
import { enableValidations, validate } from '../../../utils/validation';
import { eachLinks } from '../../../utils/links';

$(() => {
  Tinymce.init({ selector: '.template' });
  enableValidations($('.new_template'));
  $('.new_template').on('submit', (e) => {
    const links = {};
    eachLinks((ctx, value) => {
      links[ctx] = value;
    }).done(() => {
      $('#template-links').val(JSON.stringify(links));
    });
    if (!validate(e.target)) {
      e.preventDefault();
    }
  });
});
