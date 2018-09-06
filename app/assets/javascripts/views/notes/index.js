import { Tinymce } from '../../utils/tinymce';
import { isObject, isString } from '../../utils/isType';

$(() => {
  const defaultViewSelector = questionId => `#note_new${questionId}`;
  const currentViewSelector = {};
  /*
    currentViewSelector represents a map where each key is the question id and
    each value is the note view selector currently displayed. The value for a key
    should be one of:
      - #note_new${questionId}
      - #note_show${note.id}
      - #note_edit${note.id}
      - #note_archive${note.id}
  */
  const getCurrentViewSelector = questionId => currentViewSelector[questionId];
  const putCurrentViewSelector =
    (questionId, value) => {
      currentViewSelector[questionId] = value;
    };
  const initialiseCurrentViewSelector = () => {
    $('.note_new').each((i, e) => {
      const questionId = $(e).attr('data-question-id');
      putCurrentViewSelector(questionId, defaultViewSelector(questionId));
    });
  };
  const success = (data) => {
    if (isObject(data) &&
      isObject(data.notes) &&
      isString(data.notes.id) &&
      isString(data.notes.html) &&
      isObject(data.title) &&
      isString(data.title.id) &&
      isString(data.title.html)) {
      $(`#notes-${data.notes.id}`).html(data.notes.html);
      $(`#notes-title-${data.title.id}`).html(data.title.html);
    }
    clean(); // eslint-disable-line no-use-before-define
    initOrReload(); // eslint-disable-line no-use-before-define
  };
  const error = () => {
    // TODO adequate error handling for network error
  };
  const getAction = jQueryForm => jQueryForm.attr('action');
  const getMethod = jQueryForm => jQueryForm.attr('method');
  const destroyCurrentViewEditor = (el) => {
    const id = $(el).find('textarea').attr('id');
    if (id) {
      Tinymce.destroyEditorById(id);
    }
  };
  const noteNewLinkHandler = (e) => {
    const source = e.target;
    const target = $(source).attr('href');
    const questionId = $(target).attr('data-question-id');
    const viewSelectorSelected = getCurrentViewSelector(questionId);
    if (viewSelectorSelected !== target) {
      $(viewSelectorSelected)
        .hide({ complete: () => destroyCurrentViewEditor($(viewSelectorSelected)) });
      putCurrentViewSelector(questionId, target);
      $(source).css('visibility', 'hidden');
      $(target).show();
      Tinymce.init({ selector: `#${$(target).find('textarea').attr('id')}` });
    }
  };
  const noteShowLinkHandler = (e) => {
    const source = e.target;
    const target = $(source).attr('href');
    const questionId = $(target).attr('data-question-id');
    const viewSelectorSelected = getCurrentViewSelector(questionId);
    if (viewSelectorSelected !== target) {
      $(viewSelectorSelected)
        .hide({ complete: () => destroyCurrentViewEditor($(viewSelectorSelected)) });
      putCurrentViewSelector(questionId, target);
      $(source).closest('.notes').find('.note_new_link').css('visibility', 'visible');
      $(target).show();
    }
  };
  const noteEditLinkHandler = (e) => {
    const source = e.target;
    const target = $(source).attr('href');
    const questionId = $(target).attr('data-question-id');
    const viewSelectorSelected = getCurrentViewSelector(questionId);
    if (viewSelectorSelected !== target) {
      $(viewSelectorSelected)
        .hide({ complete: () => destroyCurrentViewEditor($(viewSelectorSelected)) });
      putCurrentViewSelector(questionId, target);
      $(source).closest('.notes').find('.note_new_link').css('visibility', 'hidden');
      $(target).show();
      Tinymce.init({ selector: `#${$(target).find('textarea').attr('id')}` });
    }
  };
  const noteArchiveLinkHandler = (e) => {
    const source = e.target;
    const target = $(source).attr('href');
    const questionId = $(target).attr('data-question-id');
    const viewSelectorSelected = getCurrentViewSelector(questionId);
    if (viewSelectorSelected !== target) {
      $(viewSelectorSelected)
        .hide({ complete: () => destroyCurrentViewEditor($(viewSelectorSelected)) });
      putCurrentViewSelector(questionId, target);
      $(source).closest('.notes').find('.note_new_link').css('visibility', 'hidden');
      $(target).show();
    }
  };
  const newEditNoteHandler = (e) => {
    e.preventDefault();
    const source = e.target;
    const jQueryForm = $(e.target).closest('form');
    const formElements = jQueryForm.serializeArray();
    const noteText = formElements.find(el => el.name === 'note[text]');
    const id = $(source).closest('form').find('[name="note[text]"]').attr('id');
    const questionId = $(source).closest('.note_new').attr('data-question-id') ||
      $(source).closest('.note_edit').attr('data-question-id');
    noteText.value = Tinymce.findEditorById(id).getContent();
    $.ajax({
      method: getMethod(jQueryForm),
      url: getAction(jQueryForm),
      data: formElements,
    }).done((data) => {
      Tinymce.destroyEditorById(id);
      success(data);
      putCurrentViewSelector(questionId, defaultViewSelector(questionId));
    }, error);
  };
  const archiveNoteDestroyHandler = (e) => {
    e.preventDefault();
    const source = e.target;
    const jQueryForm = $(source).closest('form');
    const formElements = jQueryForm.serializeArray();
    const questionId = $(source).closest('.note_archive').attr('data-question-id');
    $.ajax({
      method: getMethod(jQueryForm),
      url: getAction(jQueryForm),
      data: formElements,
    }).done((data) => {
      success(data);
      putCurrentViewSelector(questionId, defaultViewSelector(questionId));
    }, error);
  };
  const noteCancelHandler = (e) => {
    const source = e.target;
    const questionId = $(source).closest('.note_edit').attr('data-question-id') ||
      $(source).closest('.note_archive').attr('data-question-id');
    const viewSelectorSelected = getCurrentViewSelector(questionId);
    $(viewSelectorSelected)
      .hide({ complete: () => destroyCurrentViewEditor($(viewSelectorSelected)) });
    $(e.target).closest('.notes').find('.note_new_link').css('visibility', 'visible');
    putCurrentViewSelector(questionId, null);
  };
  const eventHandlers = ({ attachment = 'off' }) => {
    $('.notes .note_new_link')[attachment]('click', noteNewLinkHandler);
    $('.notes .note_show_link')[attachment]('click', noteShowLinkHandler);
    $('.notes .note_edit_link')[attachment]('click', noteEditLinkHandler);
    $('.notes .note_archive_link')[attachment]('click', noteArchiveLinkHandler);
    $('.new_note')[attachment]('submit', newEditNoteHandler);
    $('.edit_note')[attachment]('submit', newEditNoteHandler);
    $('.edit_note button[type="button"]')[attachment]('click', noteCancelHandler);
    $('.archive_note')[attachment]('submit', archiveNoteDestroyHandler);
    $('.archive_note button[type="button"]')[attachment]('click', noteCancelHandler);
  };
  const initOrReload = () => {
    Tinymce.init({ selector: '.note' });
    eventHandlers({ attachment: 'on' });
  };
  const clean = () => {
    eventHandlers({ attachment: 'off' });
    Tinymce.destroyEditorsByClassName('note');
  };
  initOrReload();
  initialiseCurrentViewSelector();
});
