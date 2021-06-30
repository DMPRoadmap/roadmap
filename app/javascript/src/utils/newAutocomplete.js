// import getConstant from './constants';
import debounce from './debounce';
import toggleConditionalFields from './conditional';

$(() => {
/*
  // Polyfill to support browsers that do not yet full support the native HTML5 datalist autocomplete
  // Check if datalist is supported
	const supportsDatalist = () => {

console.log(!!(document.createElement('datalist')));
console.log(window.HTMLDataListElement);
console.log('list' in document.createElement('input'));
console.log('list' in document.createElement('input') && !!(document.createElement('datalist') && window.HTMLDataListElement));

		return 'list' in document.createElement('input') && !!(document.createElement('datalist') && window.HTMLDataListElement);
	};

  const dataListToHash = (dataList) => {
    if (dataList.length > 0) {
      dataList.find('option').map((el) => { el.text });
    }
  };
*/

  const debounceAutocompleteMap = {};

  const getId = (context, attrName) => {
    if (context.length > 0) {
      const nameParts = context.attr(attrName).split('-');
      return nameParts[nameParts.length - 1];
    }
    return '';
  };

  const relatedAutocomplete = (id) => $(`[list="autocomplete-list-${id}"]`);

  const relatedNotInListCheckbox = (id) => $(`[context="not-in-list-${id}"]`);

  const relatedWarning = (id) => $(`.autocomplete-warning-${id}`);

  const relatedDataList = (id) => $(`#autocomplete-list-${id}`);

  const toggleWarning = (autocomplete) => {
    const warning = relatedWarning(getId(autocomplete, 'list'));

    if (warning.length > 0) {
      const dataList = relatedDataList(getId(autocomplete, 'list'));
      const selection = dataList.find(`option[id="${autocomplete.val()}"]`);

      if (selection.length <= 0) {
        warning.removeClass('hide').show();
      } else {
        warning.addClass('hide').hide();
      }
    }
  };

  // Quickly changing forcus triggers the call to the server
  const forceRailsRemote = debounce((autocomplete) => {
    if (autocomplete.length > 0) {
      // Force the Rails remote call
      autocomplete.blur().focus();
    }
  }, 500);

  /*
  const setPolyfillContent = (autocomplete, content) => {
    if (autocomplete.length > 0 && content) {
      autocomplete.attr('data-list-map', JSON.stringify(content));
    }
  };

  const clearDataList = (dataList) => {
    if (dataList.length > 0) {
      // If datalist is supported natively
      if (supportsDatalist()) {
        dataList.val('[]');

      } else {
        autocomplete.setAttribute('data-list-map', JSON.stringify(optionsMap));
      }
    }
  };
  */

  // Setup a debounced call to the server to query for Orgs
  const handleAutocompleteUserInput = (autocomplete) => {
    if (autocomplete.length > 0) {
      const id = getId(autocomplete, 'list');
      const dataList = relatedDataList(id);

      // Clear the existing results and show a 'Searching ...' message
      dataList.val('[]');

      // See if we already have a user action in the queue
      if (!debounceAutocompleteMap[id]) {
        // Setup a debounce for the action (e.g. wait a few milliseconds for further user input)
        debounceAutocompleteMap[id] = forceRailsRemote(autocomplete);
      } else {
        // Cancel the prior action
        debounceAutocompleteMap[id].cancel();
      }
    }
  };

  // Ad the user types we want to trigger the search
  $('body').on('keyup', '.auto-complete', (e) => {
    const autocomplete = $(e.currentTarget);
    const id = getId(autocomplete, 'list');
    const code = (e.keyCode || e.which);

    if (autocomplete.length > 0 && autocomplete.val().length > 2) {
      // Only pay attention to key presses that would actually change the contents of the field
      if ((code >= 48 && code <= 111) || (code >= 144 && code <= 222) || code === 8 || code === 9) {
        const checkbox = relatedNotInListCheckbox(id);

        if (checkbox.length > 0) {
          // Auto Uncheck the Not in List checkbox if the user is typing in this box
          checkbox.prop('checked', false);
          toggleConditionalFields(checkbox, false);
        }
        handleAutocompleteUserInput(autocomplete);
        relatedDataList(id).find('option')[0].focus();
      } else {
        e.preventDefault();
      }
    } else {
      e.preventDefault();
    }
  });

  // When the value in the Org Autocomplete changes we need to toggle the Warning message
  $('body').on('input', '.auto-complete', (e) => {
    toggleWarning($(e.currentTarget));
  });

  // Initialize any related 'not in list' conditionals
  $('.new-org-entry').on('click', (e) => {
    const checkbox = $(e.currentTarget);
    const id = getId(checkbox, 'context');
    const autocomplete = relatedAutocomplete(id);

    // Display the conditional field and then blank the contents of the autocomplete
    const checked = checkbox.prop('checked');
    toggleConditionalFields(checkbox, checked);
    autocomplete.val('');
  });

  // Hide the new org textbox on initial page load
  $('.new-org-entry').each((_idx, el) => {
    toggleConditionalFields($(el), false);
  });
/*
  // Don't run if datalist is supported natively
	if (!supportsDatalist()) {

console.log('no support for datalists');

    $('.auto-complete').on('ajax:success', (e) => {
      const autocomplete = $(e.currentTarget);
      setPolyfillContent(autocomplete, dataListToHash(relatedDataList(getId(autocomplete, 'list'))));
    });
  }
*/
});
