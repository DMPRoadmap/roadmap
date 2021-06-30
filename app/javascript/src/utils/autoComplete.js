import 'jquery-ui/autocomplete';
import getConstant from './constants';
import toggleConditionalFields from './conditional';
import toggleSpinner from './spinner';
import { isObject, isString, isArray } from './isType';

// Fetch the unique id generated for the element
const getId = (context, attrName) => {
  if (context.length > 0) {
    const nameParts = context.attr(attrName).split('-');
    return nameParts[nameParts.length - 1];
  }
  return '';
};

const relatedNotInListCheckbox = (id) => $(`[context="not-in-list-${id}"]`);

const relatedWarning = (id) => $(`.autocomplete-warning-${id}`);

const relatedJsonCrosswalk = (id) => $(`#autocomplete-crosswalk-${id}`);

const relatedSelection = (id) => $(`#autocomplete-selection-${id}`);

const relatedSuggestions = (id) => $(`#autocomplete-suggestions-${id}`);

// Updates the ARIA help text that lets the user know how many suggestions
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

// Places the results into the crosswalk, updates the Aria helper and then
// extracts the 'name' from each result and returns it for consumption by
// the JQuery UI autocomplete widget
const processAjaxResults = (autocomplete, crosswalk, results) => {
  let out = [];

  if (isObject(autocomplete) && isObject(crosswalk) && isArray(results)) {
    crosswalk.attr('value', JSON.stringify(results));
    updateAriaHelper(autocomplete, results.length);
    out = results.map((item) => item.name);
  } else {
    crosswalk.attr('value', JSON.stringify([]));
    updateAriaHelper(autocomplete, 0);
  }
  // Toggle the spinner after the AJAX call
  toggleSpinner();
  return out;
};

// Extract the AJAX query arguments from the autocomplete
const queryArgs = (autocomplete, searchTerm) => {
  const namespace = autocomplete.attr('data-namespace');
  const attribute = autocomplete.attr('data-attribute');

  return `{"${namespace}":{"${attribute}":"${searchTerm}"}}`;
};

// Makes an AJAX request to the specified target
const search = (autocomplete, term, crosswalk, callback) => {
  if (isObject(autocomplete) && isObject(crosswalk) && isString(term)) {
    const url = autocomplete.attr('data-url');
    const method = autocomplete.attr('data-method');
    const data = JSON.parse(queryArgs(autocomplete, term));

    if (isString(url) && term.length > 2) {
      // Display the spinner as we start searching via AJAX
      toggleSpinner();

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

// Looks up the value in the crosswalk
const findInCrosswalk = (selection, crosswalk) => {
  // Default to the name only
  let out = JSON.stringify({ name: selection });
  // If the user selected an item and the crosswalk exists then try to
  // find it in the crosswalk.
  if (selection.length > 0 && crosswalk.length > 0) {
    const json = JSON.parse(crosswalk.val());
    const found = json.find((item) => item != null && item.name === selection);
    // If the crosswalk was empty then out becomes undefined
    out = (found === undefined ? out : JSON.stringify(found));
  }
  return out;
};

// Returns false if the selection is the default `{"name":"[value]"}`
const warnableSelection = (selection) => {
  if (selection.length > 0) {
    const json = Object.keys(JSON.parse(selection));
    return (json.length <= 1 && json[0] === 'name');
  }
  return false;
};

// Updates the hidden id field with the contents from the crosswalk for the
// selected name
const handleSelection = (autocomplete) => {
  const id = getId(autocomplete, 'list');
  const out = findInCrosswalk(relatedSelection(id), relatedJsonCrosswalk(id));

console.log(out);

  toggleWarning(autocomplete, warnableSelection(out));

  // Set the ID and trigger the onChange event for any view specific
  // JS to trigger events
  relatedSelection(id).val(out).trigger('change');
  return true;
};

// Clear out the Sources and Crosswalk hidden fields for the given autocomplete
const scrubCrosswalkAndSource = (context) => {
  if (isObject(context) && context.length > 0) {
    const id = context.attr('id');
    const crosswalk = context.siblings(`#${id.replace('_name', '_crosswalk')}`);
    if (isObject(crosswalk) && crosswalk.length > 0) {
      crosswalk.val('[]');
    }

    const sources = context.siblings(`#${id.replace('_name', '_sources')}`);
    if (isObject(sources) && sources.length > 0) {
      sources.val('[]');
    }
  }
};

// Removes all of the Sources and Crosswalk content before form submission
const scrubOrgSelectionParamsOnSubmit = (autocomplete) => {
  const form = autocomplete.closest('form');

  if (isObject(form) && form.length > 0) {
    form.on('submit', () => {
      form.find('.auto-complete').each((_idx, el) => {
        scrubCrosswalkAndSource($(el));
      });
    });
  }
};

$(() => {
  // Initialize the org autocompletes
  $('body').find('.auto-complete').each((_idx, el) => {
    const autocomplete = $(el);
    const id = getId(autocomplete, 'list');
    const crosswalk = relatedJsonCrosswalk(id);
    const selection = relatedSelection(id);
    const suggestions = relatedSuggestions(id);
    const checkbox = relatedNotInListCheckbox(id);
    const form = autocomplete.closest('form');

    // Initialize the JQuery autocomplete functionality
    autocomplete.autocomplete({
      source: (req, resp) => search(autocomplete, req.term, crosswalk, resp),
      select: (e, ui) => handleSelection(autocomplete, selection, crosswalk, ui.item.label),
      minLength: 1,
      delay: 300,
      appendTo: suggestions,
    });

    // Initialize any related 'not in list' conditionals
    checkbox.on('click', (e) => {
      const context = $(e.currentTarget);

      // Display the conditional field and then blank the contents of the autocomplete
      const checked = context.prop('checked');
      toggleConditionalFields(context, checked);
      autocomplete.val('');
    });

    // If the crosswalk is empty, make sure it is valid JSON
    if (!crosswalk.val()) {
      crosswalk.val(JSON.stringify([]));
    }
    // Set the hidden id field to the value in the crosswalk
    // or the default `{"name":"[value in textbox]"}`
    selection.val(findInCrosswalk(autocomplete.val(), crosswalk));

    // Toggle the warning and conditional on page load
    toggleWarning(autocomplete, false);
    toggleConditionalFields(checkbox, false);

    // Set the form so that the extra autocomplete data isn't sent to the server on form submission
    if (form.length > 0) {
      form.on('submit', () => {
        relatedJsonCrosswalk.val('');

      });
    }
  });
});
