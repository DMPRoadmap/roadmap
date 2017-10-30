import debounce from '../../utils/debounce';
import ariatiseForm from '../../utils/ariatiseForm';
import initAutoComplete from '../../utils/autoComplete';
import { isObject, isArray } from '../../utils/isType';
import { isValidText } from '../../utils/isValidInputType';

$(() => {
  // AJAX error function for available template search
  const error = () => {
    // TODO: add error handling
  };

  // AJAX success function for available template search
  const success = (data) => {
    if (isObject(data) &&
        isArray(data.templates)) {
      // Display the available_templates section
      if (data.templates.length > 0) {
        data.templates.forEach((t) => {
          $('#plan_template_id').append(`<option value="${t.id}">${t.title}</option>`);
        });
        // If there is only one template, set the input field value and submit the form
        // otherwise show the dropdown list and the 'Multiple templates found message'
        if (data.templates.length === 1) {
          $('#plan_template_id option').attr('selected', 'true');
          $('#multiple-templates').hide();
        } else {
          $('#multiple-templates').show();
          $('#available-templates').fadeIn();
        }
      } else {
        error();
      }
    }
  };

  const getAction = jQueryForm => jQueryForm.attr('action');
  const getMethod = jQueryForm => jQueryForm.attr('method');

  // When one of the autocomplete fields changes, fetch the available templates
  const handleComboboxChange = debounce(() => {
    const validOrg = (isValidText($('#plan_org_id').val()) || $('#plan_no_org').prop('checked'));
    const validFunder = (isValidText($('#plan_funder_id').val()) || $('#plan_no_funder').prop('checked'));

    if (!validOrg || !validFunder) {
      $('#available-templates').fadeOut();
      $('#plan_template_id').val('');
    } else {
      // Clear out the old template dropdown contents
      $('#plan_template_id option').remove();

      // Fetch the available templates fbased on the funder and research org selected
      const jQueryForm = $('form#new_plan');
      const formElements = jQueryForm.serializeArray();
      $.ajax({
        method: getMethod(jQueryForm),
        url: getAction(jQueryForm),
        data: formElements,
      }).done(success, error);
    }
  }, 150);

  // When one of the checkboxes is clicked, disable the autocomplete input and clear its contents
  const handleCheckboxClick = (name, checked) => {
    $(`#plan_${name}_name`).prop('disabled', checked);
    $('#plan_template_id').val('').change();
    $('#available-templates').fadeOut();

    if (checked) {
      $(`#plan_${name}_name`).val('');
      $(`#plan_${name}_id`).val('-1');
      $(`#plan_${name}_name`).siblings('.combobox-clear-button').hide();
    } else {
      $(`#plan_${name}_id`).val('');
    }
    handleComboboxChange();
  };

  initAutoComplete();
  ariatiseForm({ selector: '#new_plan' });
  const defaultVisibility = $('#plan_visibility').val();

  // When the user checks the 'mock project' box we need to set the
  // visibility to 'is_test'
  $('#is_test').click((e) => {
    $('#plan_visibility').val(($(e.currentTarget)[0].checked ? 'is_test' : defaultVisibility));
  });

  // When the hidden org and funder id fields change toogle the submit button
  $('#plan_org_id, #plan_funder_id').change(() => {
    handleComboboxChange();
  });

  // Make sure the checkbox is unchecked if we're entering text
  $('.js-combobox').keyup((e) => {
    const whichOne = $(e.currentTarget).prop('id').split('_')[1];
    $(`#plan_no_${whichOne}`).prop('checked', false);
  });

  // If the user clicks the no Org/Funder checkbox disable the dropdown
  // and hide clear button
  $('#plan_no_org, #plan_no_funder').click((e) => {
    const whichOne = $(e.currentTarget).prop('id').split('_')[2];
    handleCheckboxClick(whichOne, e.currentTarget.checked);
  });

  // Initialize the form
  $('#available-templates').hide();
  handleComboboxChange();
  if ($('#plan_no_org').prop('checked')) {
    handleCheckboxClick('org', $('#plan_no_org').prop('checked'));
  }
  if ($('#plan_no_funder').prop('checked')) {
    handleCheckboxClick('funder', $('#plan_no_funder').prop('checked'));
  }
});
