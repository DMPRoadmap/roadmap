import ariatiseForm from '../../utils/ariatiseForm';
import initAutoComplete from '../../utils/autoComplete';

const handleCheckboxClick = (name, checked) => {
  $(`#plan_${name}_name`).prop('disabled', checked);
  $('#plan_template_id').val('').change();
  $('#available-templates').fadeOut();

  if (checked) {
    $(`#plan_${name}_name`).val('');
    $(`#plan_${name}_id`).val('-1').change();
    $(`#plan_${name}_name`).siblings('.combobox-clear-button').hide();
  } else {
    $(`#plan_${name}_id`).val('').change();
  }
};

const handleComboboxChange = () => {
  const validOrg = (($('#plan_org_id').val() && $('#plan_org_id').val().trim().length > 0) || $('#plan_no_org').prop('checked'));
  const validFunder = (($('#plan_funder_id').val() && $('#plan_funder_id').val().trim().length > 0) || $('#plan_no_funder').prop('checked'));

  if (!validOrg || !validFunder) {
    $('#available-templates').fadeOut();
    $('#plan_template_id').val('');
  }
};

$().ready(() => {
  initAutoComplete();
  ariatiseForm({ selector: '#create-plan' });

  const defaultVisibility = $('#plan_visibility').val();

  // Initialize the form
  handleComboboxChange();
  handleCheckboxClick('org', $('#plan_no_org').prop('checked'));
  handleCheckboxClick('funder', $('#plan_no_funder').prop('checked'));

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

  // When the form receives a valid template id enable the button
  $('#plan_template_id').change((e) => {
    $('#create_plan_submit').attr('aria-disabled', ($(e.currentTarget).val().trim().length <= 0));
  });
});
