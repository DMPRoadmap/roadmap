import ariatiseForm from '../../utils/ariatiseForm';
import initAutoComplete from '../../utils/autoComplete';
import {
  SHIBBOLETH_DISCOVERY_SERVICE_HIDE_LIST,
  SHIBBOLETH_DISCOVERY_SERVICE_SHOW_LIST,
} from '../../constants';

$(() => {
  initAutoComplete();
  ariatiseForm({ selector: '#shibboleth_ds' });

  $('a#show-create-account-via-shib-ds').click(() => {
    $('#access-control-tabs a[data-target="#create-account-form"]').tab('show');
  });

  $('#show_list').click((e) => {
    e.preventDefault();
    if ($('#full_list').is('.hide')) {
      $('#full_list').removeClass('hide').attr('aria-hidden', 'false');
      $(e.currentTarget).html(SHIBBOLETH_DISCOVERY_SERVICE_HIDE_LIST);
    } else {
      $('#full_list').addClass('hide').attr('aria-hidden', 'true');
      $(e.currentTarget).html(SHIBBOLETH_DISCOVERY_SERVICE_SHOW_LIST);
    }
  });
});
