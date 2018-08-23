import ariatiseForm from '../../utils/ariatiseForm';
import getConstant from '../../constants';
import { initOrgSelection, validateOrgSelection } from '../shared/my_org';

$(() => {
  ariatiseForm({ selector: '#shibboleth_ds' });
  initOrgSelection({ selector: '#personal_details_registration_form' });

  $('#personal_details_registration_form').on('submit', (e) => {
    // Additional validation to force the user to choose an org or type something for other
    if (!validateOrgSelection({ selector: '#personal_details_registration_form' })) {
      e.preventDefault();
    }
  });

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
