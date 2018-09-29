import { Tinymce } from '../../../utils/tinymce';
import { enableValidations, validate } from '../../../utils/validation';
import { eachLinks } from '../../../utils/links';
import { isObject, isString } from '../../../utils/isType';
import { renderNotice, renderAlert } from '../../../utils/notificationHelper';
import { scrollTo } from '../../../utils/scrollTo';

$(() => {
  Tinymce.init({ selector: '.template' });
  enableValidations($('form.edit_template .form-group:not(.link-input)'));
  // Only enable validations on the links section if it has values initially
  $('.link').each((idx, el) => {
    const linkVal = $(el).find('input[name="link_link"]').val();
    const textVal = $(el).find('input[name="link_text"]').val();
    if (isString(linkVal) && isString(textVal)) {
      // Validations are enabled if non-empty value is found
      if (linkVal.length > 0 || textVal.length > 0) {
        enableValidations(el);
      }
    }
  });

  $('.edit_template').on('ajax:before', (e) => {
    const links = {};
    eachLinks((ctx, value) => {
      links[ctx] = value;
    }).done(() => {
      $('#template-links').val(JSON.stringify(links));
    });
    return validate(e.target);
  });
  $('.edit_template').on('ajax:success', (e, data) => {
    if (isObject(data) && isString(data.msg)) {
      renderNotice(data.msg);
      scrollTo('#notification-area');
    }
  });
  $('.edit_template').on('ajax:error', (e, xhr) => {
    const error = xhr.responseJSON;
    if (isObject(error) && isString(error)) {
      renderAlert(error.msg);
      scrollTo('#notification-area');
    }
  });
});
