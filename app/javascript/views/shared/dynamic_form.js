
$(() => {
  $(document).on('click', '.madmp-fragment .actions .add-record', (e) => {
    const currentField = $(e.target.closest('.dynamic-field'));
    const clonedField = currentField.clone(true, true);

    clonedField.find('input').val(null);
    clonedField.find('.remove-record').show();

    currentField.after(clonedField);
  });

  $(document).on('click', '.madmp-fragment .actions .remove-record', (e) => {
    const currentField = $(e.target.closest('.dynamic-field'));
    currentField.remove();
  });

  // When the sub fragment modal opens
  $('#sub-fragment-modal').on('show.bs.modal', (e) => {
    // Set the modal content (loads the form)
    const link = $(e.relatedTarget).data('open');
    const parent = $(e.relatedTarget).parent();
    $.ajax({
      url: link,
      method: 'get',
      success: (data) => {
        $('#sub-fragment-modal-body').html(data);
        $('#sub-fragment-modal-body').find('#parent_form_id').val(parent.attr('for'));
        $('#sub-fragment-modal-body').find('#parent_form_index').val(parent.attr('index'));
      },
      error: (err) => {
        // eslint-disable-next-line no-console
        console.log(err);
      },
    });
  });

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

  $(document).on('change', '.schema_picker', (e) => {
    const target = $(e.target);
    const form = target.parents('.question').find('.form-answer');
    form.find('.schema_id').val(target.val());
    form.trigger('submit');
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
    const selectField = target.parents('.dynamic-field');
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
      const viewLink = selectField.find('.selected-value a');
      selectField.find('.selected-value span').html(text);
      viewLink.attr('href', viewLink.attr('href').replace(/fragment_id=([^&]+)/, `fragment_id=${value}`));
    }

    if (selectField.hasClass('multiple-select')) {
      // eslint-disable-next-line
      const confirmed = confirm('Voulez vous ajouter cet élément dans votre plan ?');
      if (confirmed) {
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
    }
  });
});
