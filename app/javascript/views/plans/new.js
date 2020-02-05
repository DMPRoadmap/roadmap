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
    if ($(context).length > 0) {
      const checkbox = $(context).find('input.toggle-autocomplete');
      return checkbox.prop('checked') || (getValue(context) !== '{}');
    }
    return false;
  };

  // When one of the autocomplete fields changes, fetch the available templates
  const handleComboboxChange = debounce(() => {
    const orgContext = $('#research-org-controls');
    const funderContext = $('#funder-org-controls');
    const validOrg = validOptions(orgContext);
    const validFunder = validOptions(funderContext);

    if (!validOrg || !validFunder) {
      $('#available-templates').fadeOut();
      $('#plan_template_id').val('');
    } else {
      // Clear out the old template dropdown contents
      $('#plan_template_id option').remove();

      let orgId = orgContext.find('input[id$="org_id"]').val();
      let funderId = funderContext.find('input[id$="funder_id"]').val();

      if (orgId.length <= 0) {
        orgId = '{}';
      }
      if (funderId.length <= 0) {
        funderId = '{}';
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
  const handleCheckboxClick = (autocomplete, checkbox, hidden) => {
    const checked = checkbox.prop('checked');

    autocomplete.prop('disabled', checked);
    hidden.val('').change();
    $('#available-templates').fadeOut();
    autocomplete.siblings('.autocomplete-warning').hide();
    autocomplete.val('');

    if (checked) {
      hidden.val('');
      toggleSubmit();
    }
    handleComboboxChange();
  };

  const initOrgSelection = (context) => {
    const section = $(context);

    if (section.length > 0) {
      initAutocomplete(`${context} .autocomplete`);

      const autocomplete = $(section).find('.autocomplete');
      const hidden = autocomplete.siblings('.autocomplete-result');
      const checkbox = $(section).find('input.toggle-autocomplete');

      autocomplete.on('change', () => {
        checkbox.prop('checked', false);
        handleComboboxChange();
      });

      checkbox.on('click', () => {
        handleCheckboxClick(autocomplete, checkbox, hidden);
      });

      if (checkbox.prop('checked')) {
        handleCheckboxClick(autocomplete, checkbox, hidden);
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
  $('#new_plan #is_test').click((e) => {
    $('#plan_visibility').val(($(e.currentTarget)[0].checked ? 'is_test' : defaultVisibility));
  });

  // Initialize the form
  $('#new_plan #available-templates').hide();
  handleComboboxChange();
  toggleSubmit();
});
