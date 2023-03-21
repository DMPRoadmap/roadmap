import { Tinymce } from '../../../utils/tinymce';

$(() => {
  if ($('#template_user_guidance_output_types').length > 0) {
    Tinymce.init({ selector: '#template_user_guidance_output_types' });
  }
  if ($('#template_user_guidance_repositories').length > 0) {
    Tinymce.init({ selector: '#template_user_guidance_repositories' });
  }
  if ($('#template_user_guidance_metadata_standards').length > 0) {
    Tinymce.init({ selector: '#template_user_guidance_metadata_standards' });
  }
  if ($('#template_user_guidance_licenses').length > 0) {
    Tinymce.init({ selector: '#template_user_guidance_licenses' });
  }
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

  function addOutputType(v, vclass) {
    const li = $('<li class="output_type" style="display: inline-block;"/>').addClass(vclass).appendTo('#my-output-types ul');
    const a = $('<a href="#" class="output_type_remove" aria-label="Remove this related work"/>').appendTo(li);
    a.on('click', (e) => {
      e.stopPropagation();
      $(e.currentTarget).parents('li.output_type').remove();
    });
    const span = $('<span style="padding: 4px; border: thin solid gray; border-radius: 5px; margin: 3px;display: inline-block;"/>').appendTo(a);
    span.text(v.replace(/^\s+|\s+$/g, ''));
    if (vclass === 'custom') {
      span.css('background-color', 'yellow');
    }
    $('<i class="fas fa-times-circle fa-reverse remove-output-type" aria-hidden="true"/>').appendTo(a);
    $('<input class="output_type" type="hidden" name="output_type[]" autocomplete="off"/>').attr('value', v).appendTo(li);
  }

  $('#customize_output_types_sel').on('change', (e) => {
    e.stopPropagation();
    if ($('#customize_output_types_sel').val() === '1') {
      $('#my-output-types ul li.standard').remove();
    } else if ($('#customize_output_types_sel').val() === '2') {
      $('#my-output-types ul li.standard').remove();
      $('#default-output-types ul li.output_type span').each((n) => {
        addOutputType($($('#default-output-types ul li.output_type span').get(n)).text(), 'standard');
      });
      $('#my-output-types ul li.custom').appendTo($('#my-output-types ul'));
    }
    showOutputTypeSelections();
  });

  $('#add_output_type').on('click', (e) => {
    const v = $('#new_output_type').val();
    if (v !== '') {
      addOutputType(v, 'custom');
    }
    $('#new_output_type').val('');
    return false;
  });
});
