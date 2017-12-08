import { isValidText } from '../../utils/isValidInputType';

$(() => {
  const combo = $('input#user_org_name');
  const id = $('input#user_org_id');
  const text = $('input#user_other_organisation');
  const link = $('a#other-org-link');

  const toggleInputs = (showCombo) => {
    if (showCombo) {
      $(text).val('').addClass('hide');
      $(combo);
    } else {
      $(combo).val('');
      $(id).val('');
      $(text).removeClass('hide');
    }
  };

  // Show the other org textbox when the link is clicked
  $(link).click((e) => {
    e.preventDefault();
    toggleInputs(false);
  });

  $(combo).keyup(() => {
    toggleInputs(true);
  });

  // Display the other org textbox if the value is filled out and no org id is selected
  if ($(id).val() && $(text).val()) {
    if ($(id).val().length <= 0 && isValidText($(text).val())) {
      toggleInputs(false);
    }
  }
});
