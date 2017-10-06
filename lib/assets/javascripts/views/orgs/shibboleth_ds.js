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
    if ($('#full_list').is('.hide')) {
      $('#full_list').show();
      $(e.currentTarget).html(SHIBBOLETH_DISCOVERY_SERVICE_HIDE_LIST);
    } else {
      $('#full_list').hide();
      $(e.currentTarget).html(SHIBBOLETH_DISCOVERY_SERVICE_SHOW_LIST);
    }
  });
});
