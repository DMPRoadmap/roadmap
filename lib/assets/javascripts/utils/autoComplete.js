import debounce from '../utils/debounce';

/*
 * Looks up the id for the text selected by the user in the jquery autocomplete combobox and
 * then sets updates the hidden id field with the id value so that its available on form submit.
 * The id-text mappings are stored as JSON in the corresponding hidden crosswalk field
 * @param the combobox element
 */
const updateIdField = (el) => {
  const crosswalk = $(`#${$(el).attr('id')}_crosswalk`);
  const idField = $(el).attr('id').replace(/_name/, '_id');

  if (crosswalk && idField) {
    const json = JSON.parse(`${$(crosswalk).val().replace(/\\"/g, '"').replace(/\\'/g, '\'')}`);
    const selection = json[$(el).val()];
    $(idField).val(selection === 'undefined' ? '' : selection).change();
  }
};

/*
 * Shows/hides the combobox's clear button based on whether or not text is present
 * @param the combobox id
 */
const toggleClearButton = (el) => {
  const clearButton = $(el).parent().find('.combobox-clear-button');
  if ($(el).val().trim().length <= 0) {
    $(clearButton).addClass('hidden');
  } else {
    $(clearButton).removeClass('hidden');
  }
};

/*
 * Wires up the jquery autocomplete combobox so that it calls the above 2 functions when the
 * user changes the text values in the combobox by typing or selecting a value
 */
export default () => {
  $('.js-combobox').each((idx, el) => {
    const debounced = debounce((e) => {
      toggleClearButton(e);
      updateIdField(e);
    }, 500);

    // When the value in the combobox changes update the hidden id field
    $(el).on('keyup', (e) => {
      debounced($(e.currentTarget));
    });

    // Clear the text and hide the button when the user clicks the clear button
    $(el).parent().find('.combobox-clear-button').on('click', () => {
      $(el).val('').focus();
      debounced($(el));
    });

    // Show/hide the clear button on page load
    toggleClearButton(el);
  });
};
