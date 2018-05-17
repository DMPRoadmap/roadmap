import getConstant from '../../../constants';
import initQuestion from '../questions/show';
import initQuestionForm from './new_edit';
import { isObject } from '../../../utils/isType';

export default (context) => {
  // The section loads with all questions in 'show' mode so init each one
  $('.question_container').each((idx, container) => {
    initQuestion($(container).attr('id'));
  });
  // When the user clicks the new question link load the new question form
  // TODO: Not sure why, but use of the Rails `remote: true` does not work,
  //       so we use AJAX here. Would be better to sue the Rails `remote:true`
  $(`#${context} .question_new_link`).on('click', (e) => {
    e.preventDefault();
    const target = $(e.target);
    const panel = target.closest('.row').find('.question_new');
    if (isObject(target) && isObject(panel)) {
      panel.html(`<span class="loading">${getConstant('AJAX_LOADING')}</span>&nbsp;&nbsp;`);
      $.get(target.attr('href'))
        .done((data) => {
          target.closest('.row').find('h4').show();
          target.hide();
          panel.html(data);
          initQuestionForm(context);
        }).fail(() => {
          panel.html(`<div class="alert alert-warning" role="alert">${getConstant('AJAX_UNABLE_TO_LOAD_TEMPLATE_SECTION_QUESTION')}</div>`);
        });
    }
  });
};
