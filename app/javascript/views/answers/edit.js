import {
  isObject,
  isNumber,
  isString,
} from '../../utils/isType';
import { Tinymce } from '../../utils/tinymce.js.erb';
import debounce from '../../utils/debounce';
import datePicker from '../../utils/datePicker';
import TimeagoFactory from '../../utils/timeagoFactory';

$(() => {
  const editorClass = 'tinymce_answer';
  const showSavingMessage = jQuery => jQuery.closest('.question-form').find('[data-status="saving"]').show();
  const hideSavingMessage = jQuery => jQuery.closest('.question-form').find('[data-status="saving"]').hide();
  const closestErrorSavingMessage = jQuery => jQuery.closest('.question-form').find('[data-status="error-saving"]');
  const questionId = jQuery => jQuery.closest('.form-answer').attr('data-autosave');
  const isStale = jQuery => jQuery.closest('.question-form').find('.answer-locking').text().trim().length !== 0;
  const isReadOnly = () => $('.form-answer fieldset:disabled').length > 0;
  const toolbar = 'bold italic | bullist numlist | link | table';
  /*
   * A map of debounced functions, one for each input, textarea or select change at any
   * form with class form-answer. The key represents a question id and the value holds
   * the debounced function for a given input, textarea or select. Note, this map is
   * populated on demand, i.e. the first time a change is made at a given input, textarea
   * or select within the form, a new key-value should be created. Succesive times, the
   * debounced function should be retrieved instead.
   */
  const debounceMap = {};
  const autoSaving = (jQuery) => {
    if (!isStale(jQuery)) {
      jQuery.closest('.form-answer').trigger('submit');
    }
  };
  const doneCallback = (data, jQuery) => {
    const form = jQuery.closest('form');
    // Validation for the data object received
    if (isObject(data)) {
      if (isObject(data.question)) { // Object related to question within data received
        if (isNumber(data.question.id)) {
          if (isString(data.question.answer_status)) {
            $(`#answer-status-${data.question.id}-research-output-${data.research_output.id}`).html(data.question.answer_status);
            TimeagoFactory.render($('time.timeago'));
          }
          if (isString(data.question.locking)) { // When an answer is stale...
            // Removes event handlers for the saved form
            detachEventHandlers(form); // eslint-disable-line no-use-before-define
            // Reflesh form view with the new partial form received
            $(`#answer-form-${data.question.id}-research-output-${data.research_output.id}`).html(data.question.form);
            // Retrieves the newly form added to the DOM
            const newForm = $(`#answer-form-${data.question.id}-research-output-${data.research_output.id}`).find('form');
            // Attaches event handlers for the new form
            attachEventHandlers(newForm); // eslint-disable-line no-use-before-define
            // Refresh optimistic locking view with the form that caused the locking
            $(`#answer-locking-${data.question.id}-research-output-${data.research_output.id}`).html(data.question.locking);
          } else { // When answer is NOT stale...
            $(`#answer-locking-${data.question.id}-research-output-${data.research_output.id}`).html('');
            $(`#answer-form-${data.question.id}-research-output-${data.research_output.id} .answer_id`).val(data.answer.id);
            if (isNumber(data.question.answer_lock_version)) {
              form.find('.answer_lock_version').val(data.question.answer_lock_version);
            }
          }
        }
      }// End Object related to question within data received
      if (isObject(data.plan)) { // Object related to plan within data received
        if (isString(data.plan.progress)) {
          $('.progress').html(data.plan.progress);
        }
      }
      /* if (isObject(data.section)) { // Object related to section within data received
        if (isNumber(data.section.id)) {
          if (isString(data.section.progress)) {
            $(`.section-progress-${data.section.id}`).html(data.section.progress);
          }
        }
      } */
      // Update answer id hidden field from data received
      // Object related to answer within data received
      if (isObject(data.answer) && isObject(data.question)) {
        if (isNumber(data.answer.id) && isNumber(data.question.id)) {
          $(`#answer-form-${data.question.id}`).find('#answer_id').val(data.answer.id);
        }
      }
    }
  };
  const failCallback = (error, jQuery) => {
    closestErrorSavingMessage(jQuery).html(
      (isObject(error.responseJSON) && isString(error.responseJSON.detail))
        ? error.responseJSON.detail : error.statusText,
    ).show();
  };
  const changeHandler = (e) => {
    const target = $(e.target);
    const id = questionId(target);
    if (!debounceMap[id]) {
      debounceMap[id] = debounce(autoSaving);
    }
    debounceMap[id](target);
  };
  const submitHandler = (e) => {
    e.preventDefault();
    const target = $(e.target);
    const form = target.closest('form');
    const id = questionId(target);
    if (debounceMap[id]) {
      // Cancels the delated execution of autoSaving
      // (e.g. user clicks the button before the delay is met)
      debounceMap[id].cancel();
    }
    $.ajax({
      method: form.attr('method'),
      url: form.attr('action'),
      data: form.serializeArray(),
      beforeSend: () => {
        showSavingMessage(target);
      },
      complete: () => {
        hideSavingMessage(target);
      },
    }).done((data) => {
      doneCallback(data, target);
    }).fail((error) => {
      failCallback(error, target);
    });
  };
  const blurHandler = (editor) => {
    const target = $(editor.getElement());
    const id = questionId(target);
    if (editor.isDirty()) {
      editor.save(); // Saves contents from editor to the textarea element
      if (!debounceMap[id]) {
        debounceMap[id] = debounce(autoSaving);
      }
      debounceMap[id](target);
    }
  };
  const focusHandler = (editor) => {
    const id = questionId($(editor.getElement()));
    if (debounceMap[id]) {
      /* Cancels the delayed execution of autoSaving, either because user
       * transitioned from an option_based question to the comment or
       * because the target element triggered blur and focus before
       * the delayed execution of autoSaving.
      */
      debounceMap[id].cancel();
    }
  };
  const formHandlers = ({ jQuery, attachment = 'off' }) => {
    // Listeners to change and submit for a form
    jQuery[attachment]('change', changeHandler);
    jQuery[attachment]('submit', submitHandler);
  };
  const editorHandlers = (editor) => {
    // Listeners to blur and focus events for a tinymce instance
    editor.on('Blur', () => blurHandler(editor));
    editor.on('Focus', () => focusHandler(editor));
  };

  const detachEditorHandlers = (editor) => {
    // Remove listeners to blur and focus events for a tinymce instance
    editor.on('Blur', () => false);
    editor.on('Focus', () => false);
  };
  /*
  Detaches events from a specific form including its tinymce editor
  @param { objecg } - jQueryForm to remove events
*/
  const detachEventHandlers = (jQueryForm) => {
    formHandlers({ jQuery: jQueryForm, attachment: 'off' });
    const tinymceId = jQueryForm.find(`.${editorClass}`).attr('id');
    detachEditorHandlers(Tinymce.findEditorById(tinymceId));
    Tinymce.destroyEditorById(tinymceId);
  };
  /*
    Attaches events for a specific form including its tinymce editor
    @param { objecg } - jQueryForm to add events
  */
  const attachEventHandlers = (jQueryForm) => {
    formHandlers({ jQuery: jQueryForm, attachment: 'on' });
    const tinymceId = jQueryForm.find(`.${editorClass}`).attr('id');
    Tinymce.init({ selector: `#${tinymceId}` });
    editorHandlers(Tinymce.findEditorById(tinymceId));
  };

  datePicker();

  // Example answer toggle
  const toggleIcon = (e) => {
    $(e.target)
      .prev('.example-answer-link')
      .find('.more-less')
      .toggleClass('fa-plus fa-minus');
  };
  $('.example-answer').on('hidden.bs.collapse', toggleIcon);
  $('.example-answer').on('shown.bs.collapse', toggleIcon);

  // TODO: Finir implé du answer_id ect...
  $('.is_common_cb').click((e) => {
    const target = $(e.currentTarget);
    const targetState = target.prop('checked');
    const parentTab = target.parents('.main_research_output');
    const sectionContent = target.parents('.section-content');
    const url = target.data('target-url');
    const answerIds = [];

    // Set answers 'is_common' hidden checkbox to the same state
    // as the master checkbox
    // Used to indicate that answers from the first research output are common to all
    parentTab.find('.ans_is_common').each((i, el) => {
      $(el).val(targetState);
    });

    // Get the id of the answers if exist
    parentTab.find('.answer_id').each((i, el) => {
      if ($(el).val()) {
        answerIds.push($(el).val());
      }
    });
    $.ajax({
      method: 'post',
      url,
      data: {
        answer_ids: answerIds,
        is_common: targetState,
      },
    }).done(() => {
      parentTab.find('.common_changed').show().fadeOut(5000);
    }).fail((error) => {
      failCallback(error, target);
    });

    // Enable or disable research outputs tabs depending on 'is_common' state
    if (targetState) {
      sectionContent.find('.research_outputs_tabs').each((i, el) => {
        $(el).addClass('disabled');
      });
    } else {
      sectionContent.find('.research_outputs_tabs').each((i, el) => {
        $(el).removeClass('disabled');
      });
    }
  }); // .click()
  $('.section-content').on('shown.bs.collapse', (e) => {
    const sectionId = $(e.target).attr('id');
    // Initial load
    TimeagoFactory.render($('time.timeago'));
    Tinymce.init({
      selector: `#${sectionId} .${editorClass}`,
      toolbar,
    });
    Tinymce.init({
      selector: `#${sectionId} .note`,
      toolbar,
    });
    if (!isReadOnly()) {
      $(`#${sectionId} .${editorClass}`).each((i, editor) => {
        // Attaches form and tinymce event handlers
        editorHandlers(Tinymce.findEditorById(`${$(editor).attr('id')}`));
      });
      formHandlers({ jQuery: $(`#${sectionId} .form-answer`), attachment: 'on' });
    } else {
      // Sets the editor mode for each editor to readonly
      Tinymce.findEditorsByClassName(editorClass).forEach((editor) => {
        editor.setMode('readonly');
      });
    }
  });
  $('.section-content').on('hide.bs.collapse', (e) => {
    const sectionId = $(e.target).attr('id');
    formHandlers({ jQuery: $(`#${sectionId} .form-answer`), attachment: 'off' });
    $(`#${sectionId} .${editorClass}`).each((i, editor) => {
      detachEditorHandlers(Tinymce.findEditorById(`${$(editor).attr('id')}`));
      Tinymce.destroyEditorById(`${$(editor).attr('id')}`);
    });
    $(`#${sectionId} .note`).each((i, editor) => {
      Tinymce.destroyEditorById(`${$(editor).attr('id')}`);
    });
  });
  $('.research_outputs_tabs a[data-toggle="tab"]').on('shown.bs.tab', (e) => {
    const researchOutputId = $(e.target).data('research-output');
    const tabsList = $(`.research_outputs_tabs a[data-research-output="${researchOutputId}"]`);
    tabsList.each((idx, tab) => {
      if (!$(tab).parent().hasClass('disabled')) {
        $(tab).tab('show');
      }
    });
  });
});
