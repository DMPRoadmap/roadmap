import { Tinymce } from '../../../utils/tinymce';
import getConstant from '../../../utils/constants';

$(() => {
  if ($('#template_user_guidance_repositories:enabled').length > 0) {
    Tinymce.init({ selector: '#template_user_guidance_repositories' });
  }
  if ($('#template_user_guidance_metadata_standards:enabled').length > 0) {
    Tinymce.init({ selector: '#template_user_guidance_metadata_standards' });
  }
});

$(() => {
  function setPrefsControls() {
    if ($('#template_enable_research_outputs:checked').is('*')) {
      $('h2.prefs_option, div.prefs_option').show();
    } else {
      $('h2.prefs_option, div.prefs_option').hide();
    }
  }
  $('#template_enable_research_outputs').on('click', () => {
    setPrefsControls();
  });
  setPrefsControls();
});

$(() => {
  $('a.output_type_remove').on('click', (e) => {
    e.stopPropagation();
    $(e.currentTarget).parents('li.output_type').remove();
  });

  function showOutputTypeSelections() {
    if ($('#customize_output_types_sel').val() === '0') {
      $('#default-output-types').show();
      $('#my-output-types').hide();
      $('#my-output-types input.output_type').attr('disabled', true);
    } else {
      $('#default-output-types').hide();
      $('#my-output-types').show();
      $('#my-output-types input.output_type').attr('disabled', false);
    }
  }
  showOutputTypeSelections();

  function checkOutputType(sel, v) {
    let res = false;
    const ns = $(sel).find('ul li.output_type span');
    ns.each((n) => {
      const node = $(ns.get(n));
      if (v === node.text()) {
        res = true;
      }
    });
    return res;
  }

  function addOutputType(v) {
    const vnorm = v.replace(/^\s+|\s+$/g, '').toLowerCase();
    const vnormDisp = vnorm.charAt(0).toUpperCase() + vnorm.slice(1);
    if (checkOutputType('#my-output-types', vnormDisp)) {
      return;
    }
    const vclass = checkOutputType('#default-output-types', vnormDisp) ? 'standard' : 'custom';
    const li = $('<li/>').addClass('selectable_item').addClass('output_type')
      .addClass(vclass)
      .appendTo('#my-output-types ul');
    const a = $('<a/>').attr('aria-label', `${getConstant('PREFS_REMOVE_OUTPUT_TYPE')} ${vnormDisp}`)
      .attr('tabindex', 0)
      .addClass('output_type_remove')
      .appendTo(li);
    a.on('click', (e) => {
      e.stopPropagation();
      $(e.currentTarget).parents('li.output_type').remove();
    });
    const span = $('<span/>').addClass('selectable_item_label').addClass(vclass).appendTo(a);
    span.text(vnormDisp);
    const index = $('#my-output-types ul li').length;
    $('<i class="fas fa-times-circle fa-reverse remove-output-type" aria-hidden="true"/>').appendTo(a);
    const name = `template[template_output_types_attributes[${index}][research_output_type]]`;
    $('<input class="output_type" type="hidden" autocomplete="off"/>').attr('name', name).attr('value', vnorm).appendTo(li);
  }

  $('input.output_type_init').each((n) => {
    const node = $($('input.output_type_init').get(n));
    addOutputType(node.val());
  }).remove();

  $('#customize_output_types_sel').on('change', (e) => {
    e.stopPropagation();
    if ($('#customize_output_types_sel').val() === '1') {
      $('#my-output-types ul li.standard').remove();
    } else if ($('#customize_output_types_sel').val() === '2') {
      $('#my-output-types ul li.standard').remove();
      $('#default-output-types ul li.output_type span').each((n) => {
        addOutputType($($('#default-output-types ul li.output_type span').get(n)).text());
      });
      $('#my-output-types ul li.custom').appendTo($('#my-output-types ul'));
    }
    showOutputTypeSelections();
  });

  $('#add_output_type').on('click', () => {
    const v = $('#new_output_type').val();
    if (v !== '') {
      addOutputType(v);
    }
    $('#new_output_type').val('');
    return false;
  });
});

$(() => {
  $('a.license_remove').on('click', (e) => {
    e.stopPropagation();
    $(e.currentTarget).parents('li.license').remove();
  });

  function showLicenseSelections() {
    if ($('#customize_licenses_sel').val() === '0') {
      $('#default-licenses').show();
      $('#my-licenses').hide();
      $('#my-licenses input.license').attr('disabled', true);
    } else {
      $('#default-licenses').hide();
      $('#my-licenses').show();
      $('#my-licenses input.license').attr('disabled', false);
    }
  }
  showLicenseSelections();

  function checkLicense(sel, v) {
    let res = false;
    const ns = $(sel).find('ul li.license');
    ns.each((n) => {
      const node = $(ns.get(n));
      const cv = node.find('input.license').val();
      if (v === cv) {
        res = true;
      }
    });
    return res;
  }

  function addLicense(id, v) {
    if (checkLicense('#my-licenses', id)) {
      return;
    }
    const vclass = checkLicense('#default-licenses', id) ? 'standard' : 'custom';
    const li = $('<li/>').addClass('selectable_item').addClass('license').addClass(vclass)
      .appendTo('#my-licenses ul');
    const a = $('<a/>')
      .attr('tabindex', 0)
      .attr('aria-label', `${getConstant('PREFS_REMOVE_LICENSE')} ${v}`).addClass('license_remove')
      .appendTo(li);
    a.on('click', (e) => {
      e.stopPropagation();
      $(e.currentTarget).parents('li.license').remove();
    });
    const span = $('<span/>').addClass('selectable_item_label').addClass(vclass).appendTo(a);
    span.text(v);
    const index = $('#my-licenses ul li').length;
    $('<i class="fas fa-times-circle fa-reverse remove-license" aria-hidden="true"/>').appendTo(a);
    const name = `template[licenses_attributes[${index}][id]]`;
    $('<input class="license" type="hidden" autocomplete="off"/>').attr('name', name).val(id).appendTo(li);
  }

  $('input.license_init').each((n) => {
    const node = $($('input.license_init').get(n));
    addLicense(node.val(), node.attr('data'));
  }).remove();

  $('#customize_licenses_sel').on('change', (e) => {
    e.stopPropagation();
    if ($('#customize_licenses_sel').val() === '1') {
      if ($('#my-licenses ul li').length === 0) {
        $('#default-licenses ul li.license').each((n) => {
          const node = $($('#default-licenses ul li.license').get(n));
          addLicense(node.find('input.license').val(), node.find('input.license').attr('data'));
        });
      }
    }
    showLicenseSelections();
  });

  $('#add_license').on('click', () => {
    const v = $('#new_license').val();
    if (v !== '') {
      addLicense(v, $('#new_license option:selected').text());
    }
    return false;
  });
});

$(() => {
  function setModalButtonRepo() {
    if ($('#template_customize_repositories:checked').is('*')) {
      $('#prefs-repositories').show();
    } else {
      $('#prefs-repositories').hide();
    }
  }
  $('#template_customize_repositories').on('change', (e) => {
    setModalButtonRepo();
  });
  setModalButtonRepo();
});

$(() => {
  function setModalButtonMetadata() {
    if ($('#template_customize_metadata_standards:checked').is('*')) {
      $('#prefs-metadata_standards').show();
    } else {
      $('#prefs-metadata_standards').hide();
    }
  }
  $('#template_customize_metadata_standards').on('change', (e) => {
    setModalButtonMetadata();
  });
  setModalButtonMetadata();
});

$(() => {
  function check(selEnable, selCount, msg) {
    if ($(selEnable).is('*')) {
      if ($(selCount).length === 0) {
        alert(msg);
        return false;
      }
    }
    return true;
  }

  $('form.edit_template').on('submit', (e) => {
    let b = true;
    b = b && check(
      '#customize_output_types_sel option[value!="0"]:selected',
      'input.output_type[type="hidden"]:enabled',
      getConstant('PREFS_REQ_OUTPUT_TYPE'),
    );
    b = b && check(
      '#template_customize_repositories:checked',
      '#modal-search-repositories-selections div.modal-search-result-label',
      getConstant('PREFS_REQ_REPOSITORY'),
    );
    b = b && check(
      '#template_customize_metadata_standards:checked',
      '#modal-search-metadata_standards-selections div.modal-search-result-label',
      getConstant('PREFS_REQ_METADATA_STANDARDS'),
    );
    b = b && check(
      '#customize_licenses_sel option[value!="0"]:selected',
      '#my-licenses input.license[type="hidden"]:enabled',
      getConstant('PREFS_REQ_LICENSE'),
    );
    if (!b) {
      e.stopPropagation();
      e.preventDefault();
    }
  });
});

$(() => {
  function showCustomRepositoryData(id, name, description, uri) {
    const dispdiv = $('<div/>').addClass('col-md-12').appendTo('div.customized_repositories');
    if (id !== '') {
      dispdiv.attr('id', id);
    }
    const divsr = $('<div/>').addClass('col-md-12').addClass('modal-search-result').appendTo(dispdiv);
    const divlabel = $('<div/>').addClass('modal-search-result-label').text(name).appendTo(divsr);
    if (id === '') {
      const sid = $('input.custom_repository_seq').length + 1000000;
      $('<input/>').attr('type', 'hidden')
        .attr('name', `template[customized_repositories_attributes[${sid}][name]]`)
        .addClass('custom_repository_seq')
        .val(name)
        .appendTo(divsr);
      $('<input/>').attr('type', 'hidden')
        .attr('name', `template[customized_repositories_attributes[${sid}][description]]`)
        .val(description)
        .appendTo(divsr);
      $('<input/>').attr('type', 'hidden')
        .attr('name', `template[customized_repositories_attributes[${sid}][uri]]`)
        .val(uri)
        .appendTo(divsr);
    } else {
      $(`#customized_repositories_id_${id}`).appendTo(divsr);
      $(`#customized_repositories_name_${id}`).appendTo(divsr);
      $(`#customized_repositories_description_${id}`).appendTo(divsr);
      $(`#customized_repositories_uri_${id}`).appendTo(divsr);
    }
    $('<a/>').addClass('modal-search-result-unselector')
      .attr('title', `Click to remove ${name}`)
      .attr('href', '#')
      .text(getConstant('PREFS_REMOVE'))
      .appendTo(divlabel);
    $('<p/>').text(description).appendTo(divsr);
    const p = $('<p/>').appendTo(divsr);
    $('<a/>').attr('href', uri).text(uri).appendTo(p);
    return divsr;
  }

  function showCustomRepository(id, name, description, uri) {
    if ($(`#customized_repositories_id_${id}`).is('*')) {
      const disp = `customized_repositories_display_${id}`;
      const dispid = `#${disp}`;
      if (!$(dispid).is('*')) {
        showCustomRepositoryData(id, name, description, uri);
      }
    }
  }

  function trimmedVal(sel) {
    return $(sel).val().replace(/^\s+/, '').replace(/\s+$/, '');
  }

  function checkEmpty(sel) {
    return trimmedVal(sel) === '';
  }
  const crs = $('input.customized_repositories');
  crs.each((n) => {
    const id = $(crs.get(n)).val();
    showCustomRepository(
      id,
      $(`#customized_repositories_name_${id}`).val(),
      $(`#customized_repositories_description_${id}`).val(),
      $(`#customized_repositories_uri_${id}`).val(),
    );
  });

  $('.custrepo').on('blur keypress', () => {
    const d = checkEmpty('#template_custom_repo_name')
            || checkEmpty('#template_custom_repo_description')
            || checkEmpty('#template_custom_repo_uri');
    $('#save_custom_repository').attr('disabled', d);
  });

  $('#save_custom_repository').on('click', (e) => {
    e.stopPropagation();
    e.preventDefault();
    showCustomRepositoryData(
      '',
      trimmedVal('#template_custom_repo_name'),
      trimmedVal('#template_custom_repo_description'),
      trimmedVal('#template_custom_repo_uri'),
    );
    $('.custrepo').val('');
    $('button.close').trigger('click');
  });
});

$(() => {
  if ($('h1.treat-page-as-read-only').is('*')) {
    $('button[data-toggle="modal"]').hide();
    $('a.output_type_remove, a.license_remove').off();
    $('a.output_type_remove i, a.license_remove i').hide();
    $('a.modal-search-result-unselector').hide();
  }
});
