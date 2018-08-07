import { Tinymce } from '../../../utils/tinymce';
import * as Validator from '../../../utils/validator';
import { eachLinks } from '../../../utils/links';
import { isObject, isString } from '../../../utils/isType';
import { renderNotice, renderAlert } from '../../../utils/notificationHelper';
import { scrollTo } from '../../../utils/scrollTo';

$(() => {
  Tinymce.init({ selector: '.template' });
  Validator.enableValidations({ selector: 'form.edit_template .form-group:not(.link-input)' });

  // TODO: Move this to the utils/links.js
  // Only enable validations on the links section if it has values initially
  $('.link').each((idx, el) => {
    const link = $(el).find('input[name="link_link"]');
    const text = $(el).find('input[name="link_text"]');
    if (isString(link.val()) && isString(text.val())) {
      // Validations are enabled if non-empty value is found
      if (link.val().length > 0 || text.val().length > 0) {
        Validator.enableValidation(link);
        Validator.enableValidation(text);
      }
    }
  });

  $('.edit_template').on('ajax:before', () => {
    const links = {};
    eachLinks((ctx, value) => {
      links[ctx] = value;
    }).done(() => {
      $('#template-links').val(JSON.stringify(links));
    });
    // return validate(e.target);
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
