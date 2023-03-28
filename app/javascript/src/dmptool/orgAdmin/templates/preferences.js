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
    if (checkOutputType('#my-output-types', vnorm)) {
      return;
    }
    const vclass = checkOutputType('#default-output-types', vnorm) ? 'standard' : 'custom';
    const li = $('<li/>').addClass('selectable_item').addClass('output_type').addClass(vclass)
      .appendTo('#my-output-types ul');
    const a = $('<a aria-label="Remove this output type"/>').addClass('output_type_remove').appendTo(li);
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
      if (v === node.find('input.license').val()) {
        res = true;
      }
    });
    return res;
  }

  function addLicense(id, v) {
    if (checkLicense('#my-licenses', id)) {
      return;
    }
    const li = $('<li/>').addClass('selectable_item').addClass('license')
      .appendTo('#my-licenses ul');
    const a = $('<a aria-label="Remove this license"/>').addClass('license_remove').appendTo(li);
    a.on('click', (e) => {
      e.stopPropagation();
      $(e.currentTarget).parents('li.license').remove();
    });
    const span = $('<span/>').addClass('selectable_item_label').appendTo(a);
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
