import ariatiseForm from '../../utils/ariatiseForm';
import initAutoComplete from '../../utils/autoComplete';
import {
  SHIBBOLETH_DISCOVERY_SERVICE_HIDE_LIST,
  SHIBBOLETH_DISCOVERY_SERVICE_SHOW_LIST,
} from '../../constants';

$(() => {
  initAutoComplete();
  ariatiseForm({ selector: '#shibboleth_ds' });

  $('#show_list').click((e) => {
    e.preventDefault();
    if ($('#full_list').is('.hidden')) {
      $('#full_list').removeClass('hidden').attr('aria-hidden', 'false');
      $(e.currentTarget).html(SHIBBOLETH_DISCOVERY_SERVICE_HIDE_LIST);
    } else {
      $('#full_list').addClass('hidden').attr('aria-hidden', 'true');
      $(e.currentTarget).html(SHIBBOLETH_DISCOVERY_SERVICE_SHOW_LIST);
    }
  });
});
