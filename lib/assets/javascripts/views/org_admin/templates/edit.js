import { Tinymce } from '../../../utils/tinymce';
import { enableValidations, validate } from '../../../utils/validation';
import { eachLinks } from '../../../utils/links';
import { isObject, isString } from '../../../utils/isType';
import { renderNotice, renderAlert } from '../../../utils/notificationHelper';
import { scrollTo } from '../../../utils/scrollTo';

$(() => {
  Tinymce.init({ selector: '.template' });
  enableValidations($('.edit_template'));
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
