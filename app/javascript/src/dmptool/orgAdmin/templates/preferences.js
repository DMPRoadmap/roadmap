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

  // Determine the styling of the selection
  const selectionClass = (defaultsBlock, label) => {
    return selectionIsDefault(defaultsBlock, label) ? 'standard' : 'custom';
  };

  const selectionRemovalButton = (label, clss) => {
    const ariaLbl = `${getConstant('PREFS_REMOVE_OUTPUT_TYPE')} ${label}`
    const btn = $(`<button type="button" aria-label="${ariaLbl}" class="selectable_item_button ${clss}"/>`);
    btn.on('click', (e) => {
      $(e.currentTarget).parents('li.selectable_item').remove();
    });
    $('<i class="fas fa-times-circle fa-reverse" aria-hidden="true"/>').appendTo(btn);
    return btn;
  };

  const generateHiddenFieldName = (nmspace, nmspacePlural) => {
    const index = $(`#my-${nmspacePlural} ul li`).length;
    if (nmspace === 'license'){
      return `template[licenses_attributes[${index}][id]]`;
    } else if (nmspace === 'output_type') {
      return `template[template_${nmspacePlural}_attributes[${index}][research_${nmspace}]]`;
    }
  };

  const addSelection = (nmspace, nmspacePlural, label, value) => {
    const txt = cleanseText(label);
    const displayTxt = nmspace === 'license' ? txt.toUpperCase() : txt.charAt(0).toUpperCase() + txt.slice(1);

    if (!selectionAlreadyDefined(`#my-${nmspacePlural} ul`, displayTxt)) {
      const li = $(`<li class="selectable_item ${nmspace}"/>`).appendTo(`#my-${nmspacePlural} ul`);

      const spanClass = selectionClass(`#default-${nmspacePlural}`, displayTxt);
      const span = $(`<span class="selectable_item_label ${spanClass}">${displayTxt}</span>`).appendTo(li);

      const hidden = $(`<input class="${nmspace}" type="hidden" autocomplete="off"/>`);
      hidden.attr('name', generateHiddenFieldName(nmspace, nmspacePlural))
            .attr('value', value.length > 0 ? value : txt)
            .appendTo(li);

      selectionRemovalButton(displayTxt, spanClass).appendTo(span);
    }
  };

  // -----------------------------------------------------------------
  // Custom Repositories
  // -----------------------------------------------------------------
  const trimmedVal = (sel) => {
    return $(sel).val().replace(/^\s+/, '').replace(/\s+$/, '');
  };

  const checkEmpty = (sel) => {
    return trimmedVal(sel) === '';
  };

  const showCustomRepository = (id, name, description, uri) => {
    if ($(`#customized_repositories_id_${id}`).is('*')) {
      const dispid = `#customized_repositories_display_${id}`;
      if (!$(dispid).is('*')) {
        toggleCustomRepositoryData(id, name, description, uri);
      }
    }
  };

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

    $('<button type="button"/>').addClass('modal-search-result-unselector')
      .attr('title', `Click to remove ${name}`)
      .text(getConstant('PREFS_REMOVE'))
      .appendTo(divlabel);
    $('<p/>').text(description).appendTo(divsr);
    const p = $('<p/>').appendTo(divsr);
    $('<a/>').attr('href', uri).text(uri).appendTo(p);
    return divsr;
  }

  // -----------------------------------------------------------------
  // Add handlers to the entire page
  // -----------------------------------------------------------------
  $('#template_enable_research_outputs').on('click', () => {
    togglePreferences();
  });

  // -----------------------------------------------------------------
  // Add handlers to Preferred OutputTypes
  // -----------------------------------------------------------------
  // Show/hide the OutputType selections
  $('#customize_output_types_sel').on('change', (e) => {
    e.stopPropagation();
    const selectedOption = $('#customize_output_types_sel option:selected').val();

    if (selectedOption === '1') {
      $('#my-output_types ul li span.standard').remove();
    } else if (selectedOption === '2') {
      $('#my-output_types ul li span.standard').remove();
      $('#default-output_types ul li.output_type span').each((n) => {
        const defaultType = $($('#default-output_types ul li.output_type span').get(n));
        if (defaultType.length > 0) {
          addSelection('output_type', 'output_types', defaultType.text(), defaultType.text());
        }
      });
      $('#my-output_types ul li.custom').appendTo($('#my-output_types ul'));
    } else {

    }
    toggleOutputTypes();
  });

  // Initialize the page with the current OutputType selections
  $('input.output_type_init').each((n) => {
    const node = $($('input.output_type_init').get(n));
    addSelection('output_type', 'output_types', node.val(), node.val());
  }).remove();

  // Add the OutputType
  $('#add_output_type').on('click', () => {
    const val = $('#new_output_type').val();
    if (val !== '') {
      addSelection('output_type', 'output_types', val, val);
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
  // Add handlers to Preferred Repositories
  // -----------------------------------------------------------------
  // Show/hide the Repository selections
  $('#template_customize_repositories').on('change', (e) => {
    toggleRepositories();
  });

  // -----------------------------------------------------------------
  // Add handlers to Custom Repositories
  // -----------------------------------------------------------------
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

  // -----------------------------------------------------------------
  // Add handlers to Preferred Metadata Standards
  // -----------------------------------------------------------------
  // Show/hide the Metadata Standard selections
  $('#template_customize_metadata_standards').on('change', (e) => {
    toggleMetadataStandards();
  });

  // -----------------------------------------------------------------
  // Add handlers to Preferred Licenses
  // -----------------------------------------------------------------
  // Show/hide the License selections
  $('#customize_licenses_sel').on('change', (e) => {
    e.stopPropagation();
    if ($('#customize_licenses_sel').val() === '1') {
      if ($('#my-licenses ul li').length === 0) {
        $('#default-licenses ul li.license').each((n) => {
          const node = $($('#default-licenses ul li.license input[type="hidden"]').get(n));
          addSelection('license', 'licenses', node.attr('data'), node.val());
        });
      }
    }
    toggleLicenses();
  });

  $('input.license_init').each((n) => {
    const node = $($('input.license_init').get(n));
    addSelection('license', 'licenses', node.attr('data'), node.val());
  }).remove();

  $('#add_license').on('click', (e) => {
    const val = $('#new_license').val();
    e.preventDefault();
    if (val !== '') {
      addSelection('license', 'licenses', $('#new_license option:selected').text(), val);
    }
  });

  // -----------------------------------------------------------------
  // Form validation
  // -----------------------------------------------------------------
  $('form.edit-template-preferences').on('submit', (e) => {
    $('ul#preference-errors li').remove();

    if (researchOutputsEnabled()) {
      let msgs = [];

      if (outputTypesEnabled()) {
        if ($('input.output_type[type="hidden"]:enabled').length <= 0) {
          msgs.push(getConstant('PREFS_REQ_OUTPUT_TYPE'));
        }
      }
      if (repositoriesEnabled()) {
        if ($('#modal-search-repositories-selections div.modal-search-result-label').length <= 0) {
          msgs.push(getConstant('PREFS_REQ_REPOSITORY'));
        }
      }
      if (metadataStandardsEnabled()) {
        if ($('#modal-search-metadata_standards-selections .modal-search-result').length <= 0) {
          msgs.push(getConstant('PREFS_REQ_METADATA_STANDARDS'));
        }
      }
      if (licensesEnabled()) {
        if ($('#my-licenses input.license[type="hidden"]:enabled').length <= 0) {
          msgs.push(getConstant('PREFS_REQ_LICENSE'));
        }
      }

      // If we had any issues, cancel the submission and display the errors
      if (msgs.length > 0) {
        e.stopPropagation();
        e.preventDefault();
        const errList = $('#preference-errors');
        for (const err of msgs) {
          $(`<li class="red">${err}</li>`).appendTo(errList);
        };
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

  if ($('h1.treat-page-as-read-only').is('*')) {
    $('button[data-toggle="modal"]').hide();
    $('a.output_type_remove, a.license_remove').off();
    $('a.output_type_remove i, a.license_remove i').hide();
    $('a.modal-search-result-unselector').hide();
  }
});
