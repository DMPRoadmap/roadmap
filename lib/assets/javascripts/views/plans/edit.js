import { Tinymce } from '../../utils/tinymce';
import { isObject, isString } from '../../utils/isType';
import { showSpinner } from '../../utils/spinner';

$(() => {
  const sectionLoadSuccess = (ctx, data) => {
    if (isObject(data) && isObject(data.section) && isString(data.section.html)) {
      ctx.html(data.section.html);
      Tinymce.init({ selector: `#${ctx.attr('id')} .tinymce_answer` });
    } else {
      ctx.html('<p class="section-failure">Unable to load this section\'s questions.</p>');
    }
  };
  const sectionLoadFailure = (ctx, error) => {
    if (isObject(error) && isString(error.msg)) {
      ctx.html(`<p class="section-failure">${error.msg}</p>`);
    } else {
      ctx.html('<p class="section-failure">An unexpected error has occurred.</p>');
    }
  };

  $('#sections-accordion').on('show.bs.collapse', (e) => {
    const target = $(e.target);
    // Only load the section content once
    if (target.find('.form-answer').length <= 0) {
      showSpinner(target);
      $.ajax({
        method: 'GET',
        url: target.attr('data-target'),
      }).done((data) => {
        sectionLoadSuccess(target, data);
      }).fail((xhr) => {
        sectionLoadFailure(target, xhr.responseJSON);
      });
    }
  });
});
