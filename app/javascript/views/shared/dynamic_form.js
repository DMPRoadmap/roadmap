
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

  $(document).on('click', '.toggle-guidance-section', (e) => {
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
      const removeButton = selectField.find('.remove-button');

      if (selected) {
        removeButton.show();
        selectField.find('.custom-value').hide();
        selectField.find('.custom-value input').val('');
      } else {
        target.parents('fieldset.registry').find('.fragment-display').hide();
        removeButton.show();
        selectField.find('.custom-value').show();
        selectField.find('.custom-value input').val(value);
        selectField.find('.custom-value span').html(value);
        selectField.find('select').val('').trigger('change');
      }
    }

    if (selectField.hasClass('linked-fragments-select')) {
      /*
      * Changes the url of the "View" link according to the selected value in the fragment select
      */
      const selectedValue = selectField.next('.selected-value');
      const viewLink = selectedValue.find('a');
      selectedValue.find('span').html(text);
      viewLink.attr('href', viewLink.attr('href').replace(/fragment_id=([^&]+)/, `fragment_id=${value}`));
      selectedValue.show();
    }

    if (selectField.hasClass('multiple-select')) {
      const messageZone = selectField.find('.message-area');
      const requestData = {
        locale: selectField.data('locale'),
        parent_id: selectField.data('parent-id'),
        schema_id: selectField.data('schema-id'),
        query_id: selectField.data('query-id'),
        property_name: selectField.data('property-name'),
      };
      if (selected) {
        requestData.registry_value_id = value;
      } else {
        requestData.custom_value = value;
      }

      $.ajax({
        url: '/madmp_fragments/create_from_registry',
        method: 'get',
        data: requestData,
      }).done((response) => {
        messageZone.hide();
        $(`table.list-${response.query_id} tbody`).html(response.html);
        selectField.find('select').val('').trigger('change');
      }).fail((response) => {
        messageZone.html(response.responseJSON.error);
        messageZone.show();
      });
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
  $(document).on('click', '.contributor-field .assign-role', (e) => {
    const target = $(e.target);
    const selectField = target.parents('.dynamic-field');
    const userData = selectField.find('.person-select select').select2('data');
    const role = selectField.find('input[type=hidden]').val();

    const requestData = {
      person_id: userData[0].id,
      role,
      locale: target.data('locale'),
      parent_id: target.data('parent-id'),
      schema_id: target.data('schema-id'),
      query_id: target.data('query-id'),
      property_name: target.data('property-name'),
    };
    $.ajax({
      url: '/madmp_fragments/create_contributor',
      method: 'get',
      data: requestData,
    }).done((response) => {
      $(`table.list-${response.query_id} tbody`).html(response.html);
    });
  });

  $(document).on('click', '.run-zone .run-button', (e) => {
    const target = $(e.target);
    const reloadButton = target.parent().find('.reload-button');
    const messageZone = target.parent().find('.message-zone');
    const loadingZone = target.parent().find('.loading-zone');
    const url = target.data('url');

    $.ajax({
      url,
      method: 'get',
      beforeSend: () => {
        target.hide();
        loadingZone.css('display', 'flex');
      },
      complete: () => {
        loadingZone.hide();
      },
    }).done((data) => {
      target.hide();
      messageZone.addClass('valid');
      messageZone.html(data.message);
      messageZone.show();
      if (data.needs_reload) {
        reloadButton.show();
      }
    }).fail((response) => {
      messageZone.html(response.responseJSON.error);
      messageZone.addClass('invalid');
      messageZone.show();
      target.show();
    });
  });

  $(document).on('click', '.run-zone .reload-button', (e) => {
    const target = $(e.target);
    target.parents('.panel-collapse').trigger('reload.form');
  });
});
