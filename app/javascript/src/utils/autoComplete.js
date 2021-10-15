import 'jquery-ui/autocomplete';
import getConstant from './constants';
import toggleConditionalFields from './conditionalFields';
import toggleSpinner from './spinner';
import {
  isObject, isString, isArray, isFunction,
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

// The JSON Array of Org names returned by the RegistryOrgsController.search method
const relatedJsonCrosswalk = (id) => $(`.autocomplete-crosswalk-${id}`);

// The <ul> version of the values in the Crosswalk that get displayed for the user
const relatedSuggestions = (id) => $(`#autocomplete-suggestions-${id}`);

// The checkbox the user can click to provide a custom Org name
const relatedNotInListCheckbox = (id) => $(`[context="not-in-list-${id}"]`);

// The textbox that the user can specify an Org name that was not one of the suggestions
const relatedCustomOrgField = (id) => $(`.user-entered-org-${id}`);

// The warning message to display to the user when the entry does not match one of the
// crosswalk items
const relatedWarning = (id) => $(`.autocomplete-warning-${id}`);

// Fetch the unique id generated for the autocomplete elements
const getId = (context, attrName) => {
  if (context.length > 0) {
    const nameParts = context.attr(attrName).split('-');
    return nameParts[nameParts.length - 1];
  }
  return '';
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
      helper.html(getConstant('AUTOCOMPLETE_ARIA_HELPER_EMPTY'));
    }
  }
};

// Places the results into the crosswalk, then updates the Aria helper and
// returns it for consumption by the JQuery UI autocomplete widget which adds
// the values to the suggestions <ul>
const processAjaxResults = (autocomplete, crosswalk, results) => {
  if (isObject(autocomplete) && isObject(crosswalk) && isArray(results)) {
    crosswalk.attr('value', JSON.stringify(results));
    updateAriaHelper(autocomplete, results.length);
  } else {
    crosswalk.attr('value', JSON.stringify([]));
    updateAriaHelper(autocomplete, 0);
  }

  // Toggle the spinner after the AJAX call
  toggleSpinner(false);
  return results;
};

// Makes an AJAX request to the specified target
const search = (autocomplete, term, crosswalk, callback) => {
  if (isObject(autocomplete) && isObject(crosswalk) && isString(term)) {
    const url = autocomplete.attr('data-url');
    const method = autocomplete.attr('data-method');
    // Format the search term so that its acceptable to the RegistryOrgsController's strong params
    const data = JSON.parse(`{"org_autocomplete":{"name":"${term}"}}`);

    if (isString(url) && term.length > 2) {
      toggleSpinner(true);

      $.ajax({
        url, method, data,
      }).done((results) => {
        callback(processAjaxResults(autocomplete, crosswalk, results));
      }).fail(() => {
        callback(processAjaxResults(autocomplete, crosswalk, []));
      });
    }
  }
};

// Shows/hides the warning message
const toggleWarning = (autocomplete, displayIt) => {
  const warning = relatedWarning(getId(autocomplete, 'list'));

  if (warning.length > 0) {
    if (displayIt) {
      warning.removeClass('hide').show();
    } else {
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

// Looks up the value in the crosswalk
const findInCrosswalk = (selection, crosswalk) => {
  const json = JSON.parse(crosswalk.val());
  return json.find((item) => isValidMatch(item, selection));
};

// Checks to see if the selection or entry in the text field matches a value in the crosswalk
const handleSelection = (autocomplete, crosswalk, selection) => {
  const out = findInCrosswalk(selection, crosswalk);
  toggleWarning(autocomplete, out === undefined);
  return true;
};

// Initialize the specified AutoComplete
export const initAutoComplete = (selector) => {
  const autocomplete = $(selector);
  const id = getId(autocomplete, 'list');
  const crosswalk = relatedJsonCrosswalk(id);
  const suggestions = relatedSuggestions(id);
  const checkbox = relatedNotInListCheckbox(id);
  const textbox = relatedCustomOrgField(id);
  const form = autocomplete.closest('form');

  // Initialize the JQuery autocomplete functionality
  autocomplete.autocomplete({
    source: (req, resp) => search(autocomplete, req.term, crosswalk, resp),
    select: (_e, ui) => handleSelection(autocomplete, crosswalk, ui.item.label),
    minLength: 1,
    delay: 300,
    appendTo: suggestions,
  });

  // If the crosswalk is empty, make sure it is valid JSON
  if (!crosswalk.val()) {
    crosswalk.val(JSON.stringify([]));
  }

  // Toggle the warning and conditional on page load
  toggleWarning(autocomplete, false);

  // When the autocomplete loses focus display the warning if they did not select an item
  autocomplete.on('blur', (e) => {
    const selection = findInCrosswalk($(e.currentTarget).val(), crosswalk);
    toggleWarning(autocomplete, selection === undefined);
  });

  // If the checkbox and textbox are present make sure they are cleared if the user starts
  // typing in the autocomplete box
  if (checkbox.length > 0) {
    autocomplete.on('input', () => {
      toggleConditionalFields(checkbox, false);
      checkbox.prop('checked', false);
    });

    // When user ticks the checkbox, display the conditional field and then blank the contents
    // of the autocomplete
    checkbox.on('click', () => {
      toggleConditionalFields(checkbox, checkbox.prop('checked'));
      autocomplete.val('');
    });

    toggleConditionalFields(checkbox, textbox.val().length > 0);
  }

  // Set the form so that the extra autocomplete data isn't sent to the server on form submission
  if (form.length > 0) {
    form.on('submit', () => {
      crosswalk.val('');
    });
  }
};

// Callable method that allows another JS file to check whether or not the autocomplete has a
// valid selection
export const listenForAutocompleteChange = (autocomplete, callback) => {
  if (autocomplete.length > 0 && isFunction(callback)) {
    const crosswalk = relatedJsonCrosswalk(getId(autocomplete, 'list'));

    if (crosswalk.length > 0) {
      // Add listener to the Select event
      autocomplete.on('autocompleteselect', (_e, ui) => {
        // Call the specified function and pass it a boolean indicating whether or not
        // the user made a valid selection
        callback(autocomplete, findInCrosswalk(ui.item.label, crosswalk));
      });

      // Add listener to the Change event
      autocomplete.on('change', () => {
        // Call the specified function and pass it a boolean indicating whether or not
        // the user made a valid selection
        callback(autocomplete, findInCrosswalk(autocomplete.val(), crosswalk));
      });
    }
  }
}
