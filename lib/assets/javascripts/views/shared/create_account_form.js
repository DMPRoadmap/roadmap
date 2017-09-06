import ariatiseForm from '../../utils/ariatiseForm';
import togglisePasswords from '../../utils/passwordHelper';
import { SHOW_SELECT_ORG_MESSAGE, SHOW_OTHER_ORG_MESSAGE } from '../../constants';

$(() => {
  ariatiseForm({ selector: '#create_account_form' });
  togglisePasswords({ selector: '#create_account_form' });

  $('#other_org_link').click((e) => {
    e.preventDefault();
    const other = $('#user_other_organisation');
    const selector = $('.combobox-container');
    if ($(other).css('display') === 'none') {
      $('#other_org_link').text(SHOW_SELECT_ORG_MESSAGE);
      $(selector).hide();
      $(other).show();
    } else {
      $('#other_org_link').text(SHOW_OTHER_ORG_MESSAGE);
      $(selector).show();
      $(other).val('').hide();
    }
  });
});
