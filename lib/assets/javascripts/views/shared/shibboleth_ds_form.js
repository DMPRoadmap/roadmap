/* eslint-env browser */ // This allows us to reference 'window' below
import ariatiseForm from '../../utils/ariatiseForm';
import initAutoComplete from '../../utils/autoComplete';
import { isObject, isString } from '../../utils/isType';
import {
  SHIBBOLETH_DISCOVERY_SERVICE_HIDE_LIST,
  SHIBBOLETH_DISCOVERY_SERVICE_SHOW_LIST,
} from '../../constants';

$(() => {
  initAutoComplete();
  ariatiseForm({ selector: '#shibboleth_ds' });

  const success = (data) => {
    // Render the html in the org-sign-in modal
    if (isObject(data) && isObject(data.org) && isString(data.org.html)) {
      $('#org-sign-in').html(data.org.html);
    }
  };
  const error = () => {
    // There was an ajax error so just route the user to the sign-in modal
    // and let them sign in as a Non-Partner Institution
    $('#access-control-tabs a[data-target="#sign-in-form"]').tab('show');
  };

  $('.org-sign-in').click((e) => {
    const target = $(e.target);
    $('#org-sign-in').html('');
    $.ajax({
      method: 'GET',
      url: target.attr('href'),
    }).done((data) => {
      success(data);
    }, error);
    e.preventDefault();
  });

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

  // When the user clicks 'Go' click the corresponding link from the list
  // of all orgs
  $('#org-select-go').click((e) => {
    e.preventDefault();
    const id = $('#org_id').val();
    if (isString(id)) {
      const link = $(`a[data-content="${id}"]`);
      if (isObject(link)) {
        // If the org doesn't have a shib setup then display the org sign in modal
        if (link.is('.org-sign-in')) {
          link.click();
        } else {
          window.location.replace(link.attr('href'));
        }
      }
    }
  });
});
