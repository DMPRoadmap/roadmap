import { Tinymce } from '../../../utils/tinymce';
import getConstant from '../../../utils/constants';

$(() => {
  // Init the TinyMCE editors for repository and standard guidance if applicable
  if ($('#template_user_guidance_repositories:enabled').length > 0) {
    Tinymce.init({ selector: '#template_user_guidance_repositories' });
  }
  if ($('#template_user_guidance_metadata_standards:enabled').length > 0) {
    Tinymce.init({ selector: '#template_user_guidance_metadata_standards' });
  }

  // -----------------------------------------------------------------
  // Usage checks
  // -----------------------------------------------------------------
  const researchOutputsEnabled = () => {
    return $('#template_enable_research_outputs').is(':checked');
  };
  const outputTypesEnabled = () => {
    return $('#customize_output_types_sel').val() !== '0';
  };
  const repositoriesEnabled = () => {
    return $('#template_customize_repositories').is(':checked');
  };
  const customRepositoriesEnabled = () => {

  };
  const metadataStandardsEnabled = () => {
    return $('#template_customize_metadata_standards').is(':checked');
  };
  const licensesEnabled = () => {
    return $('#customize_licenses_sel').val() !== '0';
  };

  const selectionIsDefault = (selector, val) => {
    return $(`${selector} li.selectable_item:contains('${val}')`).length > 0;
  };
  const selectionAlreadyDefined = (ulSelector, val) => {
    return $(`${ulSelector} .selectable_item_label:contains("${val}")`).length > 0;
  };

  const checkLicense = (selector, val) => {
    let exists = false;
    const items = $(selector).find('ul li.license');
    items.each((item) => {
      const node = $(items.get(item));
      if (val === node.find('input.license').val()) {
        exists = true;
      }
    });
    return exists;
  };

  // -----------------------------------------------------------------
  // Visibility controls
  // -----------------------------------------------------------------
  const toggleItem = (visible, selector) => {
    if (visible) {
      if ($(selector).prop("tagName") == 'input') {
        $(selector).attr('disabled', false);
      } else {
        $(selector).show();
      }
    } else {
      if ($(selector).prop("tagName") == 'input') {
        $(selector).attr('disabled', true);
      } else {
        $(selector).hide();
      }
    }
  };

  const togglePreferences = () => {
    toggleItem(researchOutputsEnabled(), 'h2.prefs_option, div.prefs_option');
  }
  const toggleOutputTypes = () => {
    const enabled = outputTypesEnabled();
    toggleItem(!enabled, '#default-output_types');
    toggleItem(enabled, '#my-output_types, #my-output_types input.output_type');
  };
  const toggleRepositories = () => {
    toggleItem(repositoriesEnabled(), '#prefs-repositories');
  };
  const toggleMetadataStandards = () => {
    toggleItem(metadataStandardsEnabled(), '#prefs-metadata_standards');
  };
  const toggleLicenses = () => {
    const enabled = licensesEnabled();
    toggleItem(!enabled, '#default-licenses');
    toggleItem(enabled, '#my-licenses, #my-licenses input.license');
  };

  // -----------------------------------------------------------------
  // Selections / User Entries
  // -----------------------------------------------------------------
  const cleanseText = (txt) => {
    return txt.replace(/^\s+|\s+$/g, '').toLowerCase();
  };
  const normalizeText = (txt) => {
    return txt.charAt(0).toUpperCase() + txt.slice(1);
  };

  // Determine the styling of the selection
  const selectionClass = (selectBoxId, defaultsBlock, label) => {
    selectionIsDefault(defaultsBlock, label) && $(selectBoxId).val() !== '1' ? 'standard' : 'custom';
  };

  const selectionRemovalButton = (li, label, clss) => {
    const ariaLbl = `${getConstant('PREFS_REMOVE_OUTPUT_TYPE')} ${label}`
    const btn = $(`<button type="button" aria-label="${ariaLbl}" class="selectable_item_button ${clss}"/>`);
    btn.on('click', (e) => {
      $(e.currentTarget).parents('li.output_type').remove();
    });
    $('<i class="fas fa-times-circle fa-reverse" aria-hidden="true"/>').appendTo(btn);
    return btn;
  };

  const addSelection = (nmspace, nmspacePlural, val) => {
    const txt = cleanseText(val);
    const displayTxt = normalizeText(txt);

console.log(`SINGULAR: ${nmspace}, PLURAL: ${nmspacePlural}, VAL: ${val}, DEFINED? ${selectionAlreadyDefined(`#my-${nmspacePlural} ul`, displayTxt)}`);

    if (!selectionAlreadyDefined(`#my-${nmspacePlural} ul`, displayTxt)) {
      const spanClass = selectionClass(`#customize_${nmspacePlural}_sel`, `#default-${nmspacePlural}`, displayTxt);
      const li = $(`<li class="selectable_item ${nmspace}"/>`).appendTo(`#my-${nmspacePlural} ul`);

console.log(`CLASS: ${spanClass}`);
console.log($(`#my-${nmspacePlural} ul`));

      const span = $(`<span class="selectable_item_label ${spanClass}">${displayTxt}</span>`).appendTo(li);

      const hidden = $(`<input class="${nmspace}" type="hidden" autocomplete="off"/>`);
      const index = $(`#my-${nmspacePlural} ul li`).length;
      const name = `template[template_${nmspacePlural}_attributes[${index}][research_${nmspace}]]`;
      hidden.attr('name', name).attr('value', txt).appendTo(li);

      selectionRemovalButton(li, displayTxt, spanClass).appendTo(span);
    }
  };

/*
  const toggleCustomRepositoryData = (id, name, description, uri) => {
    const dispdiv = $('<div/>').addClass('col-md-12').appendTo('div.customized_repositories');
    if (id !== '') {
      dispdiv.attr('id', id);
    }
    const divsr = $('<div/>').addClass('col-md-12 modal-search-result').appendTo(dispdiv);
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

  // -----------------------------------------------------------------
  // Add custom items
  // -----------------------------------------------------------------

  const addLicense = (licenseId, val) => {
    if (checkLicense('#my-licenses', licenseId)) {
      return;
    }
    const li = $('<li/>').addClass(`selectable_item license custom`).appendTo('#my-licenses ul');
    buildRemoveButton(li, val);

    const index = $('#my-licenses ul li').length;
    $('<i class="fas fa-times-circle fa-reverse remove-license" aria-hidden="true"/>').appendTo(a);
    const name = `template[licenses_attributes[${index}][id]]`;
    $('<input class="license" type="hidden" autocomplete="off"/>').attr('name', name).val(id).appendTo(li);
  };
*/


  // -----------------------------------------------------------------
  // Add handlers to the entire page
  // -----------------------------------------------------------------
  $('#template_enable_research_outputs').on('click', () => {
    togglePreferences();
  });

  // -----------------------------------------------------------------
  // Add handlers to OutputTypes
  // -----------------------------------------------------------------
  // Show/hide the OutputType selections
  $('#customize_output_types_sel').on('change', (e) => {
    e.stopPropagation();
    if ($('#customize_output_types_sel').val() === '1') {
      $('#my-output_types ul li.standard').remove();
    } else if ($('#customize_output_types_sel').val() === '2') {
      $('#my-output_types ul li.standard').remove();
      $('#default-output_types ul li.output_type span').each((n) => {
        val = $($('#default-output_types ul li.output_type span').get(n)).text();
        addSelection('output_type', 'output_types', val);
      });
      $('#my-output_types ul li.custom').appendTo($('#my-output_types ul'));
    }
    toggleOutputTypes();
  });

  // Initialize the page with the current OutputType selections
  $('input.output_type_init').each((n) => {
    const node = $($('input.output_type_init').get(n));

    addSelection('output_type', 'output_types', node.val());
  }).remove();

  // Add the OutputType
  $('#add_output_type').on('click', () => {
    const val = $('#new_output_type').val();
    if (val !== '') {
      addOutputType(v);
      addSelection('output_type', 'output_types', val);
    }
    $('#new_output_type').val('');
  });

  // Enter key should add the item not submit the form
  $('#new_output_type').on('keypress', (e) => {
    if (e.key === 'Enter') {
      e.preventDefault();
      $('#add_output_type').trigger('click');
    }
  });

  // -----------------------------------------------------------------
  // Add handlers to Repositories
  // -----------------------------------------------------------------
  // Show/hide the Repository selections
  $('#template_customize_repositories').on('change', (e) => {
    toggleRepositories();
  });

  // -----------------------------------------------------------------
  // Add handlers to Metadata Standards
  // -----------------------------------------------------------------
  // Show/hide the Metadata Standard selections
  $('#template_customize_metadata_standards').on('change', (e) => {
    toggleMetadataStandards();
  });

  // -----------------------------------------------------------------
  // Add handlers to Licenses
  // -----------------------------------------------------------------
  // Show/hide the License selections
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
    toggleLicenses();
  });



/*
  $('input.license_init').each((n) => {
    const node = $($('input.license_init').get(n));
    addLicense(node.val(), node.attr('data'));
  }).remove();

  $('#add_license').on('click', () => {
    const v = $('#new_license').val();
    if (v !== '') {
      addLicense(v, $('#new_license option:selected').text());
    }
    return false;
  });
*/

  // -----------------------------------------------------------------
  // Form validation
  // -----------------------------------------------------------------
  $('form.edit-template-preferences').on('submit', (e) => {
    if (researchOutputsEnabled()) {
      let msg = [];

      if (outputTypesEnabled()) {
        if ($('input.output_type[type="hidden"]:enabled').length <= 0) {
          msg << getConstant('PREFS_REQ_OUTPUT_TYPE');
        }
      }
      if (repositoriesEnabled()) {
        if ($('#modal-search-repositories-selections div.modal-search-result-label').length <= 0) {
          msg << getConstant('PREFS_REQ_REPOSITORY');
        }
      }
      if (metadataStandardsEnabled()) {
        if ($('#modal-search-metadata_standards-selections div.modal-search-result-label').length <= 0) {
          msg << getConstant('PREFS_REQ_METADATA_STANDARDS');
        }
      }
      if (licensesEnabled()) {
        if ($('#my-licenses input.license[type="hidden"]:enabled').length <= 0) {
          msg << getConstant('PREFS_REQ_LICENSE');
        }
      }
      // If we had any issues, cancel the submission and display the errors
      if (msg.length > 0) {
        e.stopPropagation();
        e.preventDefault();

        const errList = ('#preference-errors ul');
        msg.forEach((err) => {
          errBlock.append(`<li>${err}</li>`);
        });
      }
    }
  });

  if ($('form.edit-template-preferences').length > 0) {
    togglePreferences();
    toggleOutputTypes();
    toggleRepositories();
    toggleMetadataStandards();
    toggleLicenses();
  }










/*
  function showCustomRepository(id, name, description, uri) {
    if ($(`#customized_repositories_id_${id}`).is('*')) {
      const disp = `customized_repositories_display_${id}`;
      const dispid = `#${disp}`;
      if (!$(dispid).is('*')) {
        toggleCustomRepositoryData(id, name, description, uri);
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
    toggleCustomRepositoryData(
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
  */
});
