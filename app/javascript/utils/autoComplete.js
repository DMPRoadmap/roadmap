import 'jquery-ui/ui/widgets/autocomplete';

import getConstant from '../constants';
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
    out = results.map(item => item.name);
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

// Makes an AJAX request to the specified target
const search = (autocomplete, term, crosswalk, callback) => {
  if (isObject(autocomplete) && isObject(crosswalk) && isString(term)) {
    const url = autocomplete.attr('data-url');
    const method = autocomplete.attr('data-method');
    const data = JSON.parse(queryArgs(autocomplete, term));

    if (isString(url) && term.length > 2) {
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

// Updates the hidden id field with the contents from the crosswalk for the
// selected name
const select = (autocomplete, crosswalk) => {
  let out;

  if (isObject(autocomplete) && isObject(crosswalk)) {
    const json = JSON.parse(crosswalk.val());
    out = json.find(item => item.name === autocomplete.val());
  }
  return out ? JSON.stringify(out) : null;
};

const toggleWarning = (context, value) => {
  if (isObject(context)) {
    if (value) {
      context.addClass('hide');
    } else {
      context.removeClass('hide');
    }
  }
};

export const initAutocomplete = (selector) => {
  if (isString(selector)) {
    const context = $(selector);

    if (isObject(context) && context.length > 0) {
      const id = context.attr('id');
      const crosswalk = context.siblings(`#${id.replace('_name', '_crosswalk')}`);
      const hidden = context.siblings('.autocomplete-result');

      // If the crosswalk is empty, make sure it is valid JSON
      if (!crosswalk.val()) {
        crosswalk.val(JSON.stringify([]));
      }

      // If a data-url was defined then this is an AJAX autocomplete
      if (context.attr('data-url') && isObject(crosswalk)) {
        // Setup the autocomplete and set it's source to the appropriate
        context.autocomplete({
          source: (req, resp) => search(context, req.term, crosswalk, resp),
          minLength: 3,
          delay: 600,
        });
      } else {
        const source = context.siblings(`#${id.replace('_name', '_sources')}`);
        if (source) {
          // Setup the autocomplete and set it's source to the appropriate
          context.autocomplete({
            source: JSON.parse(source.val()),
            minLength: 1,
            delay: 300,
          });
        }
      }

      context.on('blur', () => {
        // Grab the full result id + name and stuff it into the id
        // field which is sent back to the controller for processing
        hidden.val(select(context, crosswalk));

        const warning = context.siblings('.autocomplete-warning');
        if (isObject(warning)) {
          toggleWarning(warning, hidden.val());
        }

        // If the user entered text that was NOT one of the suggestions
        if (!hidden.val()) {
          hidden.val(JSON.stringify({ name: context.val() }));
        }
      });
    }
  }
};

export { initAutocomplete as default };
