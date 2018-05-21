import getConstant from '../../../constants';
import initQuestion from '../questions/show';
import initQuestionForm from './new_edit';

export default (context) => {
  // The section loads with all questions in 'show' mode so init each one
  $('.question_container').each((idx, container) => {
    initQuestion($(container).attr('id'));
  });
  const parentSelector = '[data-context="ajaxified-section"]';
  // When the request is sent
  $(parentSelector).on('ajax:send', (e) => {
    const target = $(e.target);
    const panel = target.closest('.row').find('.question_new');
    panel.html(`<span class="loading">${getConstant('AJAX_LOADING')}</span>&nbsp;&nbsp;`);
  });
  $(parentSelector).on('ajax:success', 'a.question_new_link[data-remote="true"]', (e, data) => {
    const target = $(e.target);
    const panel = target.closest('.row').find('.question_new');
    target.closest('.row').find('h4').show();
    target.hide();
    panel.html(data);
    initQuestionForm(context);
  });
  $(parentSelector).on('ajax:error', 'a.question_new_link[data-remote="true"]', (e) => {
    const target = $(e.target);
    const panel = target.closest('.row').find('.question_new');
    panel.html(`<div class="alert alert-warning" role="alert">${getConstant('AJAX_UNABLE_TO_LOAD_TEMPLATE_SECTION_QUESTION')}</div>`);
  });
};
