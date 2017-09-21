import { Tinymce } from '../../utils/tinymce';
import { isObject, isString } from '../../utils/isType';

$(() => {
  let currentViewSelector = null;
  const success = (data) => {
    if (isObject(data) &&
      isObject(data.notes) &&
      isString(data.notes.id) &&
      isString(data.notes.html) &&
      isObject(data.title) &&
      isString(data.title.id) &&
      isString(data.title.html)) {
      clean(); // eslint-disable-line no-use-before-define
      $(`#notes-${data.notes.id}`).html(data.notes.html);
      $(`#notes-title-${data.title.id}`).html(data.title.html);
      initOrReload(); // eslint-disable-line no-use-before-define
    }
  };
  const error = () => {
    // TODO adequate error handling for network error
  };
  const getAction = jQueryForm => jQueryForm.attr('action');
  const getMethod = jQueryForm => jQueryForm.attr('method');
  const noteNewLinkHandler = (e) => {
    $(e.target).css('visibility', 'hidden');
    if (currentViewSelector) {
      $(currentViewSelector).hide();
    }
    currentViewSelector = $(e.target).attr('href');
    $(currentViewSelector).show();
  };
  const noteOtherLinkHandler = (e) => {
    $(e.target).closest('.notes').find('.note_new_link').css('visibility', 'visible');
    if (currentViewSelector) {
      $(currentViewSelector).hide();
    }
    currentViewSelector = $(e.target).attr('href');
    $(currentViewSelector).show();
  };
  const newEditNoteHandler = (e) => {
    e.preventDefault();
    const jQueryForm = $(e.target).closest('form');
    const formElements = jQueryForm.serializeArray();
    const noteText = formElements.find(el => el.name === 'note[text]');
    noteText.value = Tinymce.findEditorById($(e.target).closest('form').find('[name="note[text]"]').attr('id')).getContent();
    $.ajax({
      method: getMethod(jQueryForm),
      url: getAction(jQueryForm),
      data: formElements,
    }).done(success, error);
  };
  const archiveNoteDestroyHandler = (e) => {
    e.preventDefault();
    const jQueryForm = $(e.target).closest('form');
    const formElements = jQueryForm.serializeArray();
    $.ajax({
      method: getMethod(jQueryForm),
      url: getAction(jQueryForm),
      data: formElements,
    }).done(success, error);
  };
  const archiveNoteCancelHandler = () => {
    if (currentViewSelector) {
      $(currentViewSelector).hide();
    }
  };
  const eventHandlers = ({ attachment = 'off' }) => {
    $('.notes .note_new_link')[attachment]('click', noteNewLinkHandler);
    $('.notes .note_show_link, .notes .note_edit_link, .notes .note_archive_link')[attachment]('click', noteOtherLinkHandler);
    $('.new_note')[attachment]('submit', newEditNoteHandler);
    $('.edit_note')[attachment]('submit', newEditNoteHandler);
    $('.archive_note')[attachment]('submit', archiveNoteDestroyHandler);
    $('.archive_note button[type="button"]')[attachment]('click', archiveNoteCancelHandler);
  };
  const initOrReload = () => {
    Tinymce.init({ selector: '.note' });
    eventHandlers({ attachment: 'on' });
  };
  const clean = () => {
    currentViewSelector = null;
    eventHandlers({ attachment: 'off' });
    Tinymce.destroyEditorsByClassName('note');
  };
  initOrReload();
});
