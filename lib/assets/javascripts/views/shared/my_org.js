import { OTHER_ORG_HIDE_COMBO_MESSAGE, OTHER_ORG_SHOW_COMBO_MESSAGE } from '../../constants';
import { isValidNumber, isValidText } from '../../utils/isValidInputType';

$(() => {
  const combo = $('.combobox-container');
  const id = $('input#user_org_id');
  const text = $('input#user_other_organisation');
  const link = $('#other_org_toggle a');

  // Toggle between the autocomplete dropdown box and the other org textbox
  const toggleCombobox = (show) => {
    if (show) {
      $(text).hide();
      $(combo).fadeIn();
      $(link).text(OTHER_ORG_HIDE_COMBO_MESSAGE);
    } else {
      $(combo).hide();
      $(text).fadeIn();
      $(link).text(OTHER_ORG_SHOW_COMBO_MESSAGE);
    }
  };

  // Toggle between the combobox and textbox when the link is clicked
  $(link).click((e) => {
    e.preventDefault();
    if ($(combo).css('display') === 'none') {
      $(text).val('').hide();
      toggleCombobox(true);
    } else {
      $(combo).find('.combobox-clear-button').click();
      toggleCombobox(false);
    }
  });

  // Display the appropriate input type on page load
  if ($(id).length > 0 && $(text).length > 0) {
    toggleCombobox(isValidNumber($(id).val()) || !isValidText($(text).val()));
  }
});
