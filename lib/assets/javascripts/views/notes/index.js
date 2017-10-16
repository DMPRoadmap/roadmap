import { Tinymce } from '../../utils/tinymce';
import { isObject, isString } from '../../utils/isType';

$(() => {
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
  const getCurrentViewSelector = el => $(el).closest('.notes').find('.currentViewSelector').html();
  const setCurrentViewSelector = (el, value) => {
    $(el).closest('.notes').find('.currentViewSelector').html(value);
  };
  const destroyCurrentViewEditor = (el) => {
    const id = $(el).find('textarea').attr('id');
    if (id) {
      Tinymce.destroyEditorById(id);
    }
  };
  const noteNewLinkHandler = (e) => {
    const currentViewSelector = getCurrentViewSelector(e.target);
    const target = $(e.target).attr('href');
    if (currentViewSelector !== target) {
      $(currentViewSelector)
        .hide({ complete: () => destroyCurrentViewEditor($(currentViewSelector)) });
      setCurrentViewSelector(e.target, target);
      $(e.target).css('visibility', 'hidden');
      $(target).show();
      Tinymce.init({ selector: `#${$(target).find('textarea').attr('id')}` });
    }
  };
  const noteShowLinkHandler = (e) => {
    const currentViewSelector = getCurrentViewSelector(e.target);
    const target = $(e.target).attr('href');
    if (currentViewSelector !== target) {
      $(currentViewSelector)
        .hide({ complete: () => destroyCurrentViewEditor($(currentViewSelector)) });
      setCurrentViewSelector(e.target, target);
      $(e.target).closest('.notes').find('.note_new_link').css('visibility', 'visible');
      $(target).show();
    }
  };
  const noteEditLinkHandler = (e) => {
    const currentViewSelector = getCurrentViewSelector(e.target);
    const target = $(e.target).attr('href');
    if (currentViewSelector !== target) {
      $(currentViewSelector)
        .hide({ complete: () => destroyCurrentViewEditor($(currentViewSelector)) });
      setCurrentViewSelector(e.target, target);
      $(e.target).closest('.notes').find('.note_new_link').css('visibility', 'hidden');
      $(target).show();
      Tinymce.init({ selector: `#${$(target).find('textarea').attr('id')}` });
    }
  };
  const noteArchiveLinkHandler = (e) => {
    const currentViewSelector = getCurrentViewSelector(e.target);
    const target = $(e.target).attr('href');
    if (currentViewSelector !== target) {
      $(currentViewSelector)
        .hide({ complete: () => destroyCurrentViewEditor($(currentViewSelector)) });
      setCurrentViewSelector(e.target, target);
      $(e.target).closest('.notes').find('.note_new_link').css('visibility', 'hidden');
      $(target).show();
    }
  };
  const newEditNoteHandler = (e) => {
    e.preventDefault();
    const jQueryForm = $(e.target).closest('form');
    const formElements = jQueryForm.serializeArray();
    const noteText = formElements.find(el => el.name === 'note[text]');
    const id = $(e.target).closest('form').find('[name="note[text]"]').attr('id');
    noteText.value = Tinymce.findEditorById(id).getContent();
    $.ajax({
      method: getMethod(jQueryForm),
      url: getAction(jQueryForm),
      data: formElements,
    }).done((data) => {
      success(data);
      Tinymce.destroyEditorById(id);
    }, error);
  };
  const editNoteCancelHandler = (e) => {
    const currentViewSelector = getCurrentViewSelector(e.target);
    $(currentViewSelector)
      .hide({ complete: () => destroyCurrentViewEditor($(currentViewSelector)) });
    $(e.target).closest('.notes').find('.note_new_link').css('visibility', 'visible');
    setCurrentViewSelector(e.target, '');
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
  const archiveNoteCancelHandler = (e) => {
    const currentViewSelector = getCurrentViewSelector(e.target);
    $(currentViewSelector)
      .hide({ complete: () => destroyCurrentViewEditor($(currentViewSelector)) });
    $(e.target).closest('.notes').find('.note_new_link').css('visibility', 'visible');
    setCurrentViewSelector(e.target, '');
  };
  const eventHandlers = ({ attachment = 'off' }) => {
    $('.notes .note_new_link')[attachment]('click', noteNewLinkHandler);
    $('.notes .note_show_link')[attachment]('click', noteShowLinkHandler);
    $('.notes .note_edit_link')[attachment]('click', noteEditLinkHandler);
    $('.notes .note_archive_link')[attachment]('click', noteArchiveLinkHandler);
    $('.new_note')[attachment]('submit', newEditNoteHandler);
    $('.edit_note')[attachment]('submit', newEditNoteHandler);
    $('.edit_note button[type="button"]')[attachment]('click', editNoteCancelHandler);
    $('.archive_note')[attachment]('submit', archiveNoteDestroyHandler);
    $('.archive_note button[type="button"]')[attachment]('click', archiveNoteCancelHandler);
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
});
