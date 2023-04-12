import 'jquery-ui/ui/widgets/autocomplete';
import getConstant from './constants';
import toggleConditionalFields from './conditionalFields';
import toggleSpinner from './spinner';
import {
  isObject, isString, isFunction,
} from './isType';

// This JS file wires the Org autocomplete box up with Jquery UI's autocomplete
// functionality. The autocomplete box's source is an AJAX call to the RegistryOrg
// controller to search which searches both the org_indices and orgs tables for
// matches.
//
// JQuery places the search results into the suggestions <ul> and displays them
// to the user. We also populate a hidden crosswalk field with the same results.
// When the user makes a selection or the autocomplete box loses focus, we do a
// check to determine if the user actually selected an item from the results. If
// they did not, a warning message is displayed that tells them to tick the checkbox
// and provide a custom name for their Org
//
// Note that each Org autocomplete partial generates a unique id to prevent confusion
// and collisions when there are multiple autocompletes on the same page.
//
// The related files are:
//     controller: app/controllers/org_indices_controller.rb
//     partial:    app/views/shared/org_autocomplete.html.erb
//     css:        app/assets/stylesheets/blocks/_autocomplete.scss
//
// If applicable the Org Autocomplete widget can include a checkbox and textbox to allow a
// user to specify a custom Org name that does not appear in the autocomplete suggestions.
// For this reason some of the validation methods include checks of both fields to determine
// if the field is valid upon form submission

// The <ul> list of suggestions returned from the server based on the user's search criteria
const relatedSuggestions = (id) => $(`#autocomplete-suggestions-${id}`);

// The checkbox the user can click to provide a custom Org name
const relatedNotInListCheckbox = (id) => $(`[context="not-in-list-${id}"]`);

// The textbox that the user can specify an Org name that was not one of the suggestions
const relatedCustomOrgField = (id) => $(`.user-entered-org-${id}`);

// The warning message to display to the user when the entry does not match one of the
// crosswalk items
const relatedWarning = (id) => $(`.autocomplete-warning-${id}`);

// The default selection so we can select it on initial load
const relatedDefaultSelection = (id) => $(`.autocomplete-default-selection-${id}`);

// Fetch the unique id generated for the autocomplete elements
const getId = (context, attrName) => {
  if (context.length > 0) {
    const nameParts = context.attr(attrName).split('-');
    return nameParts[nameParts.length - 1];
  }
  return '';
};

// Determine which warning message to display based on the precense of the
// :not_in_list checkbox
const invalidSelectionMessage = (id) => {
  let msg = getConstant('AUTOCOMPLETE_ARIA_HELPER_EMPTY_WITHOUT_CUSTOM');
  if (id.length > 0) {
    if (relatedNotInListCheckbox(id).length > 0) {
      msg = getConstant('AUTOCOMPLETE_ARIA_HELPER_EMPTY_WITH_CUSTOM');
    }
  }
  return msg;
};

// Updates the ARIA help text that lets the user know how many suggestions there are and how to
// interact with the autocomplete box
const updateAriaHelper = (autocomplete, suggestionCount) => {
  if (isObject(autocomplete)) {
    const helper = autocomplete.siblings('.autocomplete-help');

    if (isObject(helper)) {
      const text = getConstant('AUTOCOMPLETE_ARIA_HELPER');
      helper.html(text.replace('%{n}', suggestionCount));
    } else {
      helper.html(invalidSelectionMessage(getId(autocomplete, 'list')));
    }
  }
};

// Makes an AJAX request to the specified target
const search = (autocomplete, term, callback) => {
  if (isObject(autocomplete) && isString(term)) {
    const url = autocomplete.attr('data-url');
    const method = autocomplete.attr('data-method');
    // Format the search term so that its acceptable to the RegistryOrgsController's strong params
    const data = JSON.parse(`{"org_autocomplete":{"name":"${term}"}}`);

    if (isString(url) && term.length > 2) {
      toggleSpinner(true);

      $.ajax({
        url, method, data,
      }).done((results) => {
        // Successful server call, so process the results
        updateAriaHelper(autocomplete, results.length);
        toggleSpinner(false);
        callback(results);
      }).fail(() => {
        // Failed server call, so clear the suggestions
        updateAriaHelper(autocomplete, 0);
        toggleSpinner(false);
        callback([]);
      });
    }
  }
};

// Shows/hides the warning message
const toggleWarning = (autocomplete, displayIt) => {
  const warning = relatedWarning(getId(autocomplete, 'list'));
  const fieldBlock = autocomplete.closest('.c-textfield');

  if (warning.length > 0) {
    if (displayIt) {
      // Show the error message and style the block accordingly
      if (fieldBlock) {
        fieldBlock.addClass('is-invalid');
      }
      updateAriaHelper(autocomplete, 0);
      warning.html(invalidSelectionMessage(getId(autocomplete, 'list')));
      warning.removeClass('hide').show();
    } else {
      // Clear the error message and remove the styling
      if (fieldBlock) {
        fieldBlock.removeClass('is-invalid');
      }
      warning.html('');
      warning.addClass('hide').hide();
    }
  }
};

// Checks whether or not the value matches (case insensitive) the search term
// ESLint wants this one on a single line but that violates the line length rule
// so disabling a rule here to allow it to span multiple lines (more readable)
/* eslint-disable arrow-body-style */
const isValidMatch = (value, searchTerm) => {
  return value !== undefined
      && value !== null
      && value.trim().toLowerCase() === searchTerm.trim().toLowerCase();
};

// Search the <ul> list of suggestions for the value in the autocomplete textbox
const isSuggestion = (selection, suggestions) => {
  const entry = suggestions.find('li.ui-menu-item')
    .filter((_idx, el) => { return isValidMatch($(el).text(), selection); });
  return entry.length > 0;
};

// Returns whether or not the autocomplete selection and user entered value are blank
const isBlank = (autocomplete, textbox) => {
  const val = autocomplete.val();
  if (textbox.length > 0) {
    return (val === undefined || val === null || val.length < 3) && textbox.val().length < 3;
  }
  return (val === undefined || val === null || val.length < 3);
};

// Determines whether the autocomplete has a valid selection or the user provided a user
// entered value (if applicable)
const isValid = (autocomplete, textbox, suggestions) => {
  const isRequired = autocomplete.parent().hasClass('is-required');
  const validAutocomplete = isSuggestion(autocomplete.val(), suggestions);

  // If both the autocomplete and user entered value are blank, check if it's required
  if (isBlank(autocomplete, textbox)) {
    return !isRequired;
  }
  // Otherwise make sure the user selected a valid suggestion
  return textbox.length > 0 ? (validAutocomplete || textbox.val().length > 2) : validAutocomplete;
};

// Checks to see if the selection or entry in the text field matches a value in the crosswalk
const handleSelection = (autocomplete, suggestions, selection) => {
  const validSelection = isSuggestion(selection, suggestions);
  toggleWarning(autocomplete, !validSelection);
  return true;
};

// Auto-select the default on initial load
const processResponse = (autocomplete, suggestions) => {
  const dflt = relatedDefaultSelection(getId(autocomplete, 'list'));
  const suggestionCount = suggestions.find('li').length;

  // If there is a default and only one suggestion then this is likely
  // the initial page load with a default Org
  if (dflt.length > 0 && dflt.text().length > 2 && suggestionCount === 1) {
    const suggestion = suggestions.find(`li:contains(${dflt.text()})`);
    // If there is a default and a matching selection then select the
    // default and focus on the first element in the form
    if (suggestion.length > 0) {
      suggestion.click();
      const fieldSelector = 'input:not([disabled]):not([type="hidden"]';
      autocomplete.closest('form').find(fieldSelector)[0].focus();
    }
  }
};

// Initialize the specified AutoComplete
export const initAutoComplete = (selector) => {
  const autocomplete = $(selector);
  const id = getId(autocomplete, 'list');
  const defaultSelection = relatedDefaultSelection(id);
  const suggestions = relatedSuggestions(id);
  const checkbox = relatedNotInListCheckbox(id);
  const textbox = relatedCustomOrgField(id);

console.log(`Initializing autocomplete for: ${selector}`);

  // Initialize the JQuery autocomplete functionality
  autocomplete.autocomplete({
    source: (req, resp) => search(autocomplete, req.term, resp),
    select: (_e, ui) => handleSelection(autocomplete, suggestions, ui.item.label),
    open: () => processResponse(autocomplete, suggestions),
    minLength: 1,
    delay: 300,
    appendTo: suggestions,
  });

  // Toggle the warning and conditional on page load
  toggleWarning(autocomplete, false);

  // When the autocomplete changes or loses focus display the warning if they did not select or
  // enter an item from the suggestion list
  autocomplete.on('blur change keyup', (e) => {
    const validSelection = isSuggestion($(e.currentTarget).val(), suggestions);
    toggleWarning(autocomplete, !validSelection);
  });

  autocomplete.closest('form').on('submit', (e) => {
    const valid = isValid(autocomplete, textbox, suggestions);
    if (!valid) {
      toggleWarning(autocomplete, !valid);
      e.preventDefault();
    }
  });

  // If a default Org was provided, trigger the search to populate the suggestions
  if (defaultSelection.length > 0 && defaultSelection.text().length > 2) {
    autocomplete.autocomplete('search', defaultSelection.text().trim());
  }

  // If the checkbox and textbox are present make sure they are cleared if the user starts
  // typing in the autocomplete box
  if (checkbox.length > 0) {
    autocomplete.on('input', () => {
      toggleConditionalFields(checkbox, false);
      checkbox.prop('checked', false);
      checkbox.val('0');
      textbox.val('');
    });

    // When user ticks the checkbox, display the conditional field and then blank the contents
    // of the autocomplete
    checkbox.on('click', () => {
      toggleConditionalFields(checkbox, checkbox.prop('checked'));
      autocomplete.val('');
    });

    // Clear the warning message if the user has entered a custom Org
    textbox.on('keyup', () => {
      if (textbox.val().length >= 3) {
        toggleWarning(autocomplete, false);
      }
    });

    toggleConditionalFields(checkbox, textbox.val().length > 0);
  }
};

// Callable method that allows another JS file to check whether or not the autocomplete has a
// valid selection
export const listenForAutocompleteChange = (autocomplete, callback) => {
  if (autocomplete.length > 0 && isFunction(callback)) {
    const suggestions = relatedSuggestions(getId(autocomplete, 'list'));

    if (suggestions.length > 0) {
      // Add listener to the Select event
      autocomplete.on('autocompleteselect', (_e, ui) => {
        // Call the specified function and pass it a boolean indicating whether or not
        // the user made a valid selection
        callback(autocomplete, ui.item.label);
      });

      // Add listener to the Change event
      autocomplete.on('change', () => {
        // Call the specified function and pass it a boolean indicating whether or not
        // the user made a valid selection
        callback(autocomplete, autocomplete.val());
      });
    }
  }
};

// Helper method to allow other JS files to hide/show the autocomplete error/warning message
export const hideWarning = (autocomplete) => {
  if (autocomplete.length > 0 && autocomplete.hasClass('ui-autocomplete-input')) {
    toggleWarning(autocomplete, false);
  }
};

export const showWarning = (autocomplete) => {
  if (autocomplete.length > 0 && autocomplete.hasClass('ui-autocomplete-input')) {
    toggleWarning(autocomplete, true);
  }
};
