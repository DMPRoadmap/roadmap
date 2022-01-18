import debounce from '../utils/debounce';
import getConstant from '../utils/constants';
import { listenForAutocompleteChange } from '../utils/autoComplete';
import toggleSpinner from '../utils/spinner';
import { isArray, isString } from '../utils/isType';
import { renderAlert, hideNotifications } from '../utils/notificationHelper';

$(() => {
  // Org autocompletes
  const researchOrg = $('#org_autocomplete_name');
  const funderOrg = $('#org_autocomplete_funder_name');

  // Org checkboxes
  const noResearchOrg = $('#plan_no_org');
  const noFunderOrg = $('#plan_no_funder');

  // Enables/Disables the submit button based on whether or not a template is selected
  const toggleSubmit = () => {
    const tmplt = $('#plan_template_id').find(':selected').val();
    const title = $('#plan_title').val();

    if (isString(tmplt) && title.length > 0) {
      $('#new_plan button[type="submit"]').removeAttr('disabled')
        .removeAttr('data-toggle').removeAttr('title');
    } else {
      $('#new_plan button[type="submit"]').attr('disabled', true)
        .attr('data-toggle', 'tooltip').attr('title', getConstant('NEW_PLAN_DISABLED_TOOLTIP'));
    }
  };

  const clearTemplateOptions = () => {
    $('#available-templates').fadeOut();
    $('#plan_template_id').find(':selected').removeAttr('selected');
    $('#plan_template_id').val('');
    toggleSubmit();
  };

  const validOptions = () => {
    const orgVal = $('#org_autocomplete_name').val();
    const noOrg = $('#plan_no_org').prop('checked');
    const funderVal = $('#org_autocomplete_funder_name').val();
    const noFunder = $('#plan_no_funder').prop('checked');

    return (orgVal.length > 0 || noOrg) && (funderVal.length > 0 || noFunder);
  };

  // Handle a successful search for available templatess based on the Research Org and Funder
  const ajaxSuccess = (data) => {
    if (data !== undefined && isArray(data.templates)) {
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
          $('#available-templates').fadeOut();
        } else {
          $('#multiple-templates').show();
          $('#available-templates').fadeIn();
        }
      }
      toggleSubmit();
    }
    toggleSpinner();
  };

  // Displays an error message if no templates are returned for some reason
  const ajaxError = () => {
    renderAlert(getConstant('NO_TEMPLATE_FOUND_ERROR'));
    toggleSpinner();
  };

  // Perform an AJAX call to search for templates based on the Research Org and Funder
  const templateSearch = debounce((researchOrgName, funderOrgName) => {
    hideNotifications();

    const data = `{"org_autocomplete":{"name":"${researchOrgName}","funder_name":"${funderOrgName}"}}`;
    toggleSpinner();

    $.ajax({
      url: $('#template-option-target').val(),
      data: JSON.parse(data),
    }).done(ajaxSuccess).fail(ajaxError);
  }, 250);

  // One of the autocomplete boxes changed so perform a search!
  const processAutocompleteChange = (autocomplete, selection) => {
    clearTemplateOptions();

    if (validOptions()) {
      const name = selection === undefined ? '' : selection;

console.log(name);
console.log(selection);

      if (autocomplete.attr('id') === researchOrg.attr('id')) {
        templateSearch(name, funderOrg.val());
      } else {
        templateSearch(researchOrg.val(), name);
      }
    }
  };

  // When one of the checkboxes is clicked, disable the autocomplete input and clear its contents
  const handleCheckboxClick = (autocomplete, checkbox) => {
    // Clear and then Disable/Enable the textbox and hide
    // any textbox warnings
    const checked = checkbox.prop('checked');
    autocomplete.val('');
    autocomplete.prop('disabled', checked);
    autocomplete.siblings('.autocomplete-result').val('');
    autocomplete.siblings('.autocomplete-warning').hide();

    processAutocompleteChange(autocomplete, '');
  };

  // Attach event listeners to the org autocomplete boxes
  if (researchOrg.length > 0 && funderOrg.length > 0) {
    listenForAutocompleteChange(researchOrg, processAutocompleteChange);
    listenForAutocompleteChange(funderOrg, processAutocompleteChange);
  }

  // Listen for the no org/funder checkbox clicks
  if (noResearchOrg.length > 0 && noFunderOrg.length > 0) {
    noResearchOrg.on('click', () => {
      handleCheckboxClick(researchOrg, noResearchOrg);
    });
    noFunderOrg.on('click', () => {
      handleCheckboxClick(funderOrg, noFunderOrg);
    });
  }

  // When the user checks the 'mock project' box we need to set the
  // visibility to 'is_test'
  $('#new_plan #is_test').click((e) => {
    const defaultVisibility = $('#plan_visibility').val();
    $('#plan_visibility').val(($(e.currentTarget)[0].checked ? 'is_test' : defaultVisibility));
  });

  $('#plan_title').on('input', () => {
    toggleSubmit();
  });

  // Initialize the form
  $('#new_plan #available-templates').hide();
  toggleSubmit();
});
