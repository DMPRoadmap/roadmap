import Swal from 'sweetalert2';

export const Select2 = {
  init(questionId = null, inModal = false) {
    $(`${questionId} .select-field select, ${questionId} .schema-picker-zone select`).select2({
      theme: 'bootstrap',
      dropdownParent: inModal ? $('#modal_fragment_form') : $('body'),
    });
  },
};
export const projectSelectorHandler = (selectField, value, text) => {
  const overlay = $('#plan_project .overlay');
  const errorZone = $('#plan_project .error-zone');
  // eslint-disable-next-line
  Swal.fire({
    text: `Souhaitez vous charger les données du projet "${text}" dans votre plan ?`,
    showDenyButton: true,
    width: 500,
  }).then((result) => {
    if (result.isConfirmed) {
      $.ajax({
        url: '/codebase/anr_search',
        method: 'get',
        data: {
          project_id: value,
          fragment_id: selectField.data('fragment-id'),
          script_id: selectField.data('script-id'),
        },
        beforeSend: () => {
          overlay.show();
          errorZone.hide();
        },
      }).done(() => {
        selectField.find('select').val('').trigger('change');
        $('#plan_project').trigger('reload.form');
        $('#plan_metadata').trigger('reload.form');
        $('#plan_project .project-selector').fadeOut();
      }).fail((response) => {
        errorZone.html(response.responseJSON.error);
        errorZone.show();
        overlay.hide();
      });
    }
  });
};

export const createFromRegistryHandler = (selectField, value, selected) => {
  const messageZone = selectField.find('.message-area');
  const requestData = {
    locale: selectField.data('locale'),
    parent_id: selectField.data('parent-id'),
    schema_id: selectField.data('schema-id'),
    query_id: selectField.data('query-id'),
    property_name: selectField.data('property-name'),
    readonly: selectField.data('readonly'),
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
};

export const contributorCreationHandler = (selectField, value) => {
  const contributorField = selectField.parents('.contributor-field');
  const role = contributorField.find('input[type=hidden]').val();

  const requestData = {
    person_id: value,
    role,
    locale: contributorField.data('locale'),
    parent_id: contributorField.data('parent-id'),
    schema_id: contributorField.data('schema-id'),
    query_id: contributorField.data('query-id'),
    property_name: contributorField.data('property-name'),
    readonly: contributorField.data('readonly'),
  };
  $.ajax({
    url: '/madmp_fragments/create_contributor',
    method: 'get',
    data: requestData,
  }).done((response) => {
    $(`table.list-${response.query_id} tbody`).html(response.html);
    selectField.find('select').val('').trigger('change');
  });
};

export const linkedFragmentSelectorHandler = (selectField, value, text) => {
  /*
  * Changes the url of the "View" link according to the selected value in the fragment select
  */
  const selectedValue = selectField.next('.selected-value');
  const viewLink = selectedValue.find('a');
  selectedValue.find('span').html(text);
  viewLink.attr('href', viewLink.attr('href').replace(/fragment_id=([^&]+)/, `fragment_id=${value}`));
  selectedValue.show();
};

export const singleSelectHandler = (selectField, target, value, selected) => {
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
};

export const multiSelectHandler = (selectField, value, text) => {
  const lastSelectedValue = selectField.find('.selected-value:last-child');
  if (lastSelectedValue.is(':only-child') && lastSelectedValue.find('input').val() === '') {
    lastSelectedValue.find('input').val(value);
    lastSelectedValue.find('.value-text').html(text);
    lastSelectedValue.show();
  } else {
    const clonedLastValue = lastSelectedValue.clone();
    clonedLastValue.find('input').val(value);
    clonedLastValue.find('.value-text').html(text);
    selectField.find('.selected-values').append(clonedLastValue);
    selectField.find('select').val('').trigger('change');
  }
};

export default Select2;
