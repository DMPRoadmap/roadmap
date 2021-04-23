
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
    const selectField = target.parents('.select-field');
    const data = selectField.find('select').select2('data');
    const value = data[0].id;
    const text = data[0].text;
    const selected = data[0].selected;

    if (!value) return;

    if (selectField.hasClass('single-select') && target.data('tags') === true) {
      if (selected) {
        selectField.find('.custom-value').hide();
        selectField.find('.custom-value input').val('');
      } else {
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
    }

    if (selectField.hasClass('multiple-select')) {
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
        $(`table.list-${response.query_id} tbody`).html(response.html);
        selectField.find('select').val('').trigger('change');
      });
    }
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

  $(document).on('click', '.answer-run-zone .run-button', (e) => {
    const target = $(e.target);
    const reloadButton = target.parent().find('.reload-button');
    const messageZone = target.parent().find('.message-zone');
    const url = target.data('url');

    $.ajax({
      url,
      method: 'get',
      beforeSend: () => {
        target.prop('disabled', true);
      },
    }).done(() => {
      target.hide();
      messageZone.show();
      reloadButton.show();
    });
  });

  $(document).on('click', '.answer-run-zone .reload-button', () => {
    // eslint-disable-next-line no-restricted-globals
    location.reload();
  });
});
