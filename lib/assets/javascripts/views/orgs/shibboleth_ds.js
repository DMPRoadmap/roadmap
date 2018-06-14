import ariatiseForm from '../../utils/ariatiseForm';
import getConstant from '../../constants';
import initMyOrgCombobox from '../shared/my_org';

$(() => {
  ariatiseForm({ selector: '#shibboleth_ds' });
  initMyOrgCombobox({ selector: '#personal_details_registration_form' });

  $('#show_list').click((e) => {
    e.preventDefault();
    if ($('#full_list').is('.hidden')) {
      $('#full_list').removeClass('hidden').attr('aria-hidden', 'false');
      $(e.currentTarget).html(getConstant('SHIBBOLETH_DISCOVERY_SERVICE_HIDE_LIST'));
    } else {
      $('#full_list').addClass('hidden').attr('aria-hidden', 'true');
      $(e.currentTarget).html(getConstant('SHIBBOLETH_DISCOVERY_SERVICE_SHOW_LIST'));
    }
  });
});
