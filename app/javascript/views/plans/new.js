import debounce from '../../utils/debounce';
import { initAutocomplete } from '../../utils/autoComplete';
import getConstant from '../../constants';
import { isObject, isArray, isString } from '../../utils/isType';
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
    if (isObject(data)
        && isArray(data.templates)) {
      // Display the available_templates section
      if (data.templates.length > 0) {
        data.templates.forEach((t) => {
          $('#plan_template_id').append(`<option value="${t.id}">${t.title}</option>`);
        });
        // If there is only one template, set the input field value and submit the form
        // otherwise show the dropdown list and the 'Multiple templates found message'
        if (data.templates.length === 1) {
          const templateTitle = data.templates[0].title;
          $('#plan_template_id option').attr('selected', 'true');
          $('#multiple-templates').hide();
          if ($('#plan_org_id').val() !== '-1') {
            if ($('#single-template .single-template-name').length) {
              $('#single-template .single-template-name .template_title').html(templateTitle);
            }
            $('#create-btn').show();
            $('#single-template').show();
            $('#no-template').hide();
            $('#default-template').hide();
          } else if ($('#plan_funder_id').val() !== '-1') {
            if ($('#single-template .single-template-name').length) {
              $('#single-template .single-template-name .template_title').html(templateTitle);
            }
            $('#create-btn').show();
            $('#single-template').show();
            $('#no-template').hide();
          }
        } else {
          $('#multiple-templates').show();
          $('#no-template').hide();
          $('#available-templates').fadeIn();
          $('#single-template, #default-template').hide();
          $('#create-btn').show();
        }
        toggleSubmit();
      } else {
        $('#no-template').show();
        $('#single-template').hide();
        $('#default-template').hide();
      }
    }
  };


  // TODO: Refactor this whole thing when we redo the create plan
  //       workflow and use js.erb instead!
  const getValue = (context) => {
    if (context.length > 0) {
      const hidden = $(context).find('.autocomplete-result');
      if (hidden.length > 0 && hidden.val().length > 0
         && hidden.val() !== '{}' && hidden.val() !== '{"name":""}') {
        return hidden.val();
      }
    }
    return '{}';
  };

  const validOptions = (context) => {
    let ret = false;
    if ($(context).length > 0) {
      const checkbox = $(context).find('input.toggle-autocomplete');
      const val = getValue(context);
      if (val.length > 0 && val !== '{}') {
        const json = JSON.parse(val);
        // If the json ONLY contains a name then it is not a valid selection
        ret = (checkbox.prop('checked') || json.id !== undefined);
      } else {
        // Otherwise just focus on the checkbox
        ret = checkbox.prop('checked');
      }
    }
    return ret;
  };

  // When one of the autocomplete fields changes, fetch the available templates
  const handleComboboxChange = debounce(() => {
    const ownOrgContext = $('#own-org-controls');
    const orgContext = $('#research-org-controls');
    const funderContext = $('#funder-org-controls');
    const validOwnOrg = validOptions(ownOrgContext);
    const validOrg = validOptions(orgContext);
    const validFunder = validOptions(funderContext);


    if (!validOwnOrg || !validOrg || !validFunder) {
      $('#available-templates').fadeOut();
      $('#plan_template_id').find(':selected').removeAttr('selected');
      $('#plan_template_id').val('');
      toggleSubmit();
    } else {
      // Clear out the old template dropdown contents
      $('#plan_template_id option').remove();

      let orgId = orgContext.find('input[id$="org_id"]').val();
      let funderId = funderContext.find('input[id$="funder_id"]').val();

      // For some reason Rails freaks out it everything is empty so send
      // the word "none" instead and handle on the controller side
      if (orgId.length <= 0) {
        orgId = '"none"';
      }
      if (funderId.length <= 0) {
        funderId = '"none"';
      }
      const data = `{"plan": {"research_org_id":${orgId},"funder_id":${funderId}}}`;

      // Fetch the available templates based on the funder and research org selected
      $.ajax({
        url: $('#template-option-target').val(),
        data: JSON.parse(data),
      }).done(success).fail(error);
    }
  }, 150);

  // When one of the checkboxes is clicked, disable the autocomplete input and clear its contents
  const handleCheckboxClick = (autocomplete, checkbox) => {
    // Clear and then Disable/Enable the textbox and hide
    // any textbox warnings
    const checked = checkbox.prop('checked');
    autocomplete.val('');
    autocomplete.prop('disabled', checked);
    autocomplete.siblings('.autocomplete-result').val('');
    autocomplete.siblings('.autocomplete-warning').hide();

    handleComboboxChange();
  };

  const initOrgSelection = (context) => {
    const section = $(context);

    if (section.length > 0) {
      initAutocomplete(`${context} .autocomplete`);

      const autocomplete = $(section).find('.autocomplete');
      const hidden = autocomplete.siblings('.autocomplete-result');
      const checkbox = $(section).find('input.toggle-autocomplete');

      hidden.on('change', () => {
        handleComboboxChange();
      });

      checkbox.on('click', () => {
        handleCheckboxClick(autocomplete, checkbox);
      });

      if (checkbox.prop('checked')) {
        handleCheckboxClick(autocomplete, checkbox);
      }
    }
  };

  ['#research-org-controls', '#funder-org-controls'].forEach((el) => {
    if ($(el).length > 0) {
      initOrgSelection(el);
    }
  });

  const defaultVisibility = $('#plan_visibility').val();

  // When the user checks the 'mock project' box we need to set the
  // visibility to 'is_test'
  $('#new_plan #is_test').on('click', (e) => {
    $('#plan_visibility').val(($(e.currentTarget)[0].checked ? 'is_test' : defaultVisibility));
  });

  // Make sure the checkbox is unchecked if we're entering text
  $('#new_plan #plan_org_id, #new_plan #plan_funder_id').on('change', (e) => {
    const [, whichOne] = $(e.currentTarget).prop('id').split('_');
    $(`#plan_no_${whichOne}`).prop('checked', false);
    handleComboboxChange();
  });

  // If the user clicks the no Org/Funder checkbox disable the dropdown
  // and hide clear button
  $('#new_plan #plan_no_org, #new_plan #plan_no_funder').on('click', (e) => {
    const [, , whichOne] = $(e.currentTarget).prop('id').split('_');
    handleCheckboxClick(whichOne, e.currentTarget.checked);
  });

  // Initialize the form
  $('#new_plan #available-templates').hide();
  handleComboboxChange();
  toggleSubmit();

  // For form v2

  // Clicking on the 'Next' button activates the next tabs
  $('#next-btn').on('click', (e) => {
    e.preventDefault();
    const nextTabId = $('.form-tabs li.active').next().children().attr('href');
    if (nextTabId) $(`.nav-tabs span[data-target="${nextTabId}"]`).tab('show');
  });

  // Watch for tab change for dynamic buttons ('Next' and 'Default Template')
  $('span[data-toggle="tab"]').on('shown.bs.tab', () => {
    const activeTab = $('.form-tabs li.active a').attr('href');
    const lastTab = $('.form-tabs li a').last().attr('href');
    if (activeTab === lastTab) {
      $('#next-btn').hide();
    } else {
      $('#next-btn').show();
    }
  });

  // First and second tab are equivalent to checking the "No funder" checkbox
  $('span[data-target="#own-org-controls"], span[data-target="#research-org-controls"]').on('shown.bs.tab', () => {
    handleCheckboxClick(
      $('#research-org-controls .autocomplete'),
      $('#plan_no_org').prop('checked', false),
    );
    handleCheckboxClick(
      $('#funder-org-controls .autocomplete'),
      $('#plan_no_funder').prop('checked', true),
    );
  });

  // Empty combobox on second tab activation
  const emptyTab = () => {
    // $('#plan_org_id').val('-1');
    $('#plan_org_name').val('');
    $('#single-template, #default-template, #no-template').hide();
  };

  // Empty combobox on second & third tab activation
  $('span[data-target="#research-org-controls"], span[data-target="#funder-org-controls"]').on('shown.bs.tab', emptyTab);
  $('span[data-target="#research-org-controls"], span[data-target="#funder-org-controls"]').on('hidden.bs.tab', emptyTab);

  // Restore default organisation when activating first tab
  $('span[data-target="#own-org-controls"]').on('shown.bs.tab', () => {
    handleCheckboxClick(
      $('#research-org-controls .autocomplete'),
      $('#plan_no_org').prop('checked', true),
    );
    handleCheckboxClick(
      $('#funder-org-controls .autocomplete'),
      $('#plan_no_funder').prop('checked', true),
    );
    handleComboboxChange();
  });

  //  Last tab is equivalent to checking the "No org" checkbox
  $('span[data-target="#funder-org-controls"]').on('shown.bs.tab', () => {
    handleCheckboxClick(
      $('#research-org-controls .autocomplete'),
      $('#plan_no_org').prop('checked', true),
    );
    handleCheckboxClick(
      $('#funder-org-controls .autocomplete'),
      $('#plan_no_funder').prop('checked', false),
    );
  });

  $('#new_plan #plan_title').on('change', (e) => {
    const planTitle = encodeURI(e.target.value);
    const regex = /plan%5Btitle%5D=([^&]+)/;
    const defaultBtn = $('#new_plan #create-plan-link');
    if (!defaultBtn.attr('href').match(regex)) {
      defaultBtn.attr('href', `${defaultBtn.attr('href')}&plan%5Btitle%5D=${planTitle}`);
    } else {
      defaultBtn.attr('href', defaultBtn.attr('href').replace(regex, `plan%5Btitle%5D=${planTitle}`));
      defaultBtn.attr('href').replace(regex, `plan%5Btitle%5D=${planTitle}`);
    }
  });
});
