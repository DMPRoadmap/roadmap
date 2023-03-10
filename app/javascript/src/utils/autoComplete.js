import 'jquery-ui/autocomplete';
import getConstant from './constants';
import { isObject, isString, isArray } from './isType';

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
  return out;
};

// Extract the AJAX query arguments from the autocomplete
const queryArgs = (autocomplete, searchTerm) => {
  const namespace = autocomplete.attr('data-namespace');
  const attribute = autocomplete.attr('data-attribute');

  return `{"${namespace}":{"${attribute}":"${searchTerm}"}}`;
};

// Displays/hides a 'Loading ...' message while waiting for an AJAX response
const toggleLoadingMessage = (context) => {
  const selections = $(context);
  const msg = getConstant('AUTOCOMPLETE_SEARCHING');
  const loadingMessage = `<li class="loading-message ui-menu-item"><div class="ui-menu-item-wrapper" tabindex="-1">${msg}</div></li>`;

  if (selections.length > 0) {
    const message = selections.find('.loading-message');
    const menu = selections.find('ul.ui-menu');

    menu.show();

    if (message.length > 0) {
      message.remove();
    } else {
      menu.html(loadingMessage);
    }
  }
};

// Makes an AJAX request to the specified target
const search = (autocomplete, term, crosswalk, callback) => {
  if (isObject(autocomplete) && isObject(crosswalk) && isString(term)) {
    const url = autocomplete.attr('data-url');
    const method = autocomplete.attr('data-method');
    const data = JSON.parse(queryArgs(autocomplete, term));

    if (isString(url) && term.length > 2) {
      toggleLoadingMessage(autocomplete.siblings('div[id$="_ui-front"]'));

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
  const warning = autocomplete.siblings('.autocomplete-warning');

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
const handleSelection = (autocomplete, hidden, crosswalk, selection) => {
  const out = findInCrosswalk(selection, crosswalk);

  toggleWarning(autocomplete, warnableSelection(out));

  // Set the ID and trigger the onChange event for any view specific
  // JS to trigger events
  hidden.val(out).trigger('change');
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
export const scrubOrgSelectionParamsOnSubmit = (formSelector) => {
  const form = $(formSelector);

  if (isObject(form) && form.length > 0) {
    form.on('submit', () => {
      form.find('.autocomplete').each((_idx, el) => {
        scrubCrosswalkAndSource($(el));
      });
    });
  }
};

export const initAutocomplete = (selector) => {
  if (isString(selector)) {
    const context = $(selector);

    if (isObject(context) && context.length > 0) {
      const id = context.attr('id');
      const front = context.siblings('div[id$="_ui-front"]');
      const crosswalk = context.siblings(`#${id.replace('_name', '_crosswalk')}`);
      const hidden = context.siblings('.autocomplete-result');

      toggleWarning(context, false);

      // If the crosswalk is empty, make sure it is valid JSON
      if (!crosswalk.val()) {
        crosswalk.val(JSON.stringify([]));
      }

      // If a data-url was defined then this is an AJAX autocomplete
      if (context.attr('data-url') && isObject(crosswalk)) {
        // Setup the autocomplete and set it's source to the appropriate
        context.autocomplete({
          source: (req, resp) => search(context, req.term, crosswalk, resp),
          select: (e, ui) => handleSelection(context, hidden, crosswalk, ui.item.label),
          minLength: 3,
          delay: 600,
          appendTo: front,
        });
      } else {
        const source = context.siblings(`#${id.replace('_name', '_sources')}`);
        if (source) {
          // Setup the autocomplete and set it's source to the appropriate
          context.autocomplete({
            source: JSON.parse(source.val()),
            select: (e, ui) => handleSelection(context, hidden, crosswalk, ui.item.label),
            minLength: 1,
            delay: 300,
            appendTo: front,
          });
        }
      }

      // Handle manual entry (instead of autocomplete selection)
      context.on('keyup', (e) => {
        const code = (e.keyCode || e.which);
        // Only pay attention to key presses that would actually
        // change the contents of the field
        if ((code >= 48 && code <= 111) || (code >= 144 && code <= 222)
             || code === 8 || code === 9) {
          handleSelection(context, hidden, crosswalk, context.val());
        }
      });

      // Set the hidden id field to the value in the crosswalk
      // or the default `{"name":"[value in textbox]"}`
      hidden.val(findInCrosswalk(context.val(), crosswalk));
    }
  }
};
export default initAutocomplete;
