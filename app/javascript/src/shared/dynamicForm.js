import {
  projectSelectorHandler,
  multipleSelectorHandler,
  linkedFragmentSelectorHandler,
  contributorCreationHandler,
  singleSelectHandler,
} from '../utils/select2';

$(() => {
  // When clicking on the "+" of a duplicable field, clone the field & remove
  // the value from the cloned field
  $(document).on('click', '.madmp-fragment .actions .add-record', (e) => {
    const currentField = $(e.target.closest('.dynamic-field'));
    const clonedField = currentField.clone(true, true);

    clonedField.find('input').val(null);
    clonedField.find('.remove-record').show();

    currentField.after(clonedField);
  });

  // When clicking on the "-" of a duplicable field, remove the field
  $(document).on('click', '.madmp-fragment .actions .remove-record', (e) => {
    const currentField = $(e.target.closest('.dynamic-field'));
    currentField.remove();
  });

  // On fragment list, when clicking on the delete button, send a DELETE HTTP
  // request to the server
  $(document).on('click', '.linked-fragments-list .actions .delete', (e) => {
    const target = $(e.target);
    // TODO : replace confirm()
    // eslint-disable-next-line
    const confirmed = confirm(target.data('confirm-message'));
    if (confirmed) {
      $.ajax({
        url: target.data('url'),
        method: 'delete',
      }).done((data) => {
        $(`table.list-${data.query_id} tbody`).html(data.html);
      });
    }
  });

  $(document).on('click', '.toggle-guidance-section:not(.disabled)', (e) => {
    const target = $(e.currentTarget);
    target.parents('.question-body').find('.guidance-section').toggle();
    target.find('span.fa-chevron-right, span.fa-chevron-left')
      .toggleClass('fa-chevron-right')
      .toggleClass('fa-chevron-left');
  });

  $(document).on('select2:select', (e) => {
    const target = $(e.target);

    if (target.hasClass('schema_picker')) return;

    const selectField = target.parents('.select-field');
    const data = selectField.find('select').select2('data');
    const value = data[0].id;
    const text = data[0].text;
    const selected = data[0].selected;

    if (!value) return;

    if (selectField.hasClass('single-select') && target.data('tags') === true) {
      singleSelectHandler(selectField, target, value, selected);
    }

    if (selectField.hasClass('linked-fragments-select')) {
      if (selectField.hasClass('multiple-selector')) {
        contributorCreationHandler(selectField, value, text);
      } else {
        linkedFragmentSelectorHandler(selectField, value, text);
      }
    }

    if (selectField.hasClass('multiple-select')) {
      multipleSelectorHandler(selectField, value, selected);
    }

    if (selectField.hasClass('project-selector')) {
      projectSelectorHandler(selectField, value, text);
    }
  });

  $(document).on('click', '.select-field .remove-button', (e) => {
    const target = $(e.target);
    const selectField = target.parents('.select-field');

    target.parents('fieldset.registry').find('.fragment-display').hide();
    selectField.find('.custom-value').hide();
    selectField.find('.custom-value input').val('__DELETED__');
    selectField.find('select').val('').trigger('change');
  });

  $(document).on('click', '.run-zone .run-button', (e) => {
    const target = $(e.target);
    const messageZone = target.parent().find('.message-zone');
    const overlay = target.parents('.fragment-content').find('.overlay');
    const url = target.data('url');

    $.ajax({
      url,
      method: 'get',
      beforeSend: () => {
        target.hide();
        overlay.show();
      },
      complete: () => {
        overlay.hide();
      },
    }).done((data) => {
      target.hide();
      if (data.needs_reload) {
        target.parents('.fragment-content').trigger('reload.form');
      } else {
        messageZone.addClass('valid');
        messageZone.html(data.message);
        messageZone.show();
      }
    }).fail((response) => {
      messageZone.html(response.responseJSON.error);
      messageZone.addClass('invalid');
      messageZone.show();
      target.show();
    });
  });

  // $(document).on('click', '.run-zone .reload-button', (e) => {
  //   const target = $(e.target);
  //   target.parents('.panel-collapse').trigger('reload.form');
  // });

  $(document).on('click', '.project-selector-link', () => {
    $('#plan_project').find('.project-selector').fadeIn();
    $('#plan_project .error-zone').fadeOut();
  });
  $(document).on('click', '.cancel-project-search', () => {
    $('#plan_project').find('.project-selector').fadeOut();
    $('#plan_project .error-zone').fadeOut();
  });
});
