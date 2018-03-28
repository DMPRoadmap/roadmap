import debounce from '../../utils/debounce';
import ariatiseForm from '../../utils/ariatiseForm';
import initAutoComplete from '../../utils/autoComplete';
import getConstant from '../../constants';
import { isObject, isArray, isString } from '../../utils/isType';
import { isValidText } from '../../utils/isValidInputType';
import { renderAlert, hideNotifications } from '../../utils/notificationHelper';

$(() => {
  const toggleSubmit = () => {
    const tmplt = $('#plan_template_id').find(':selected').val();
    if (isString(tmplt)) {
      $('#new_plan button[type="submit"]').removeAttr('disabled')
        .removeAttr('data-toggle').removeAttr('title');
    } else {
      $('#new_plan button[type="submit"]').attr('disabled', true)
        .attr('data-toggle', 'tooltip').attr('title', getConstant('NEW_PLAN_DISABLED_TOOLTIP'));
    }
  };

  // AJAX error function for available template search
  const error = () => {
    renderAlert(getConstant('NO_TEMPLATE_FOUND_ERROR'));
  };

  // AJAX success function for available template search
  const success = (data) => {
    hideNotifications();

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
        toggleSubmit();
      } else {
        error();
      }
    }
  };

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

      // Fetch the available templates based on the funder and research org selected
      const qryStr = `?plan[org_id]=${$('#plan_org_id').val()}&plan[funder_id]=${$('#plan_funder_id').val()}`;
      $.ajax({
        url: `${$('#template-option-target').val()}${qryStr}`,
      }).done(success).fail(error);
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
  ariatiseForm({ selector: '#new_plan', excludeAsterisks: true });
  const defaultVisibility = $('#plan_visibility').val();

  // When the user checks the 'mock project' box we need to set the
  // visibility to 'is_test'
  $('#new_plan #is_test').click((e) => {
    $('#plan_visibility').val(($(e.currentTarget)[0].checked ? 'is_test' : defaultVisibility));
  });

  // Make sure the checkbox is unchecked if we're entering text
  $('#new_plan #plan_org_id, #new_plan #plan_funder_id').change((e) => {
    const whichOne = $(e.currentTarget).prop('id').split('_')[1];
    $(`#plan_no_${whichOne}`).prop('checked', false);
    handleComboboxChange();
  });

  // If the user clicks the no Org/Funder checkbox disable the dropdown
  // and hide clear button
  $('#new_plan #plan_no_org, #new_plan #plan_no_funder').click((e) => {
    const whichOne = $(e.currentTarget).prop('id').split('_')[2];
    handleCheckboxClick(whichOne, e.currentTarget.checked);
  });

  // Initialize the form
  $('#new_plan #available-templates').hide();
  handleComboboxChange();
  toggleSubmit();

  if ($('#plan_no_org').prop('checked')) {
    handleCheckboxClick('org', $('#plan_no_org').prop('checked'));
  }
  if ($('#plan_no_funder').prop('checked')) {
    handleCheckboxClick('funder', $('#plan_no_funder').prop('checked'));
  }
});
