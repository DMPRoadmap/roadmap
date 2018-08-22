import { isObject } from '../../utils/isType';
import { isValidText } from '../../utils/isValidInputType';

export const initOrgSelection = (options) => {
  if (isObject(options) && options.selector) {
    const div = $(options.selector);

    if (isObject(div)) {
      const combo = div.find('input.js-combobox');
      const id = div.find('input.org-id');
      const name = div.find('input[name="user[org_name]"]');
      const text = div.find('input.other-org');
      const link = div.find('a.other-org-link');
      const otherOrg = div.find('input[name="user[other_org_id]"]');
      const otherOrgName = div.find('input[name="user[other_org_name]"]');

      const toggleInputs = (showCombo) => {
        if (showCombo) {
          text.val('').addClass('hide');
        } else {
          combo.val('');
          id.val('');
          text.removeClass('hide');
        }
      };

      // Show the other org textbox when the link is clicked
      link.click((e) => {
        e.preventDefault();
        toggleInputs(false);
      });

      combo.keyup(() => {
        toggleInputs(true);
      });

      // when the user enters a value in the 'Other org' textbox, set the org_id to OTHER_ORG_ID
      text.blur(() => {
        if (isObject(id)) {
          id.val(text.val().length > 0 ? otherOrg.val() : '');
          name.val(text.val().length > 0 ? otherOrgName.val() : '');
        }
      });

      // Display the other org textbox if the value is filled out and no org id is selected
      if (isValidText(id.val())) {
        if (id.val().toString() === otherOrg.val().toString()) {
          toggleInputs(false);
        }
      }
    }
  }
};

export const validateOrgSelection = (options) => {
  if (isObject(options) && options.selector) {
    const orgId = $(`${options.selector} [name="user[org_id]"]`);
    const otherOrg = $(`${options.selector} [name="user[other_organisation]"]`);

    if (isObject(orgId) || isObject(otherOrg)) {
      if (isValidText(orgId.val()) || isValidText(otherOrg.val())) {
        $('#help-org').hide();
        return true;
      }
      $('#help-org').show();
      return false;
    }
  }
  return false;
};
