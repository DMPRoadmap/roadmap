
$(() => {
  const displayROInputs = (researchOutputDiv) => {
    researchOutputDiv.find('.input').each((idx, inp) => {
      $(inp).show();
    });
    researchOutputDiv.find('.readonly-value').each((idx, val) => {
      $(val).hide();
    });
  };


  $('#research-outputs').sortable({
    handle: '.research-output-actions .handle',
    stop: () => {
      $('#research-outputs .research-output-element').each(function callback(index) {
        $(this).find('.research-output-order').val(index + 1);
      });
    },
  });

  $('#add-research-output').click(() => {
    const lastResearchOutput = $('#research-outputs .research-output-element').last();
    const lastResearchOutputOrder = parseInt(lastResearchOutput.find('.research-output-order').val(), 10);
    const duplicated = lastResearchOutput.clone(true, true);
    const duplicatedId = `plan_research_outputs_attributes_${new Date().getTime()}`;
    const duplicatedName = `plan[research_outputs_attributes][${new Date().getTime()}]`;
    const editElement = duplicated.find('.edit');
    const cancelElement = duplicated.find('.cancel');
    const deleteElement = duplicated.find('.delete');

    // Research Output abbreviation
    duplicated.find('.research-output-abbreviation input').attr('id', `${duplicatedId}_abbreviation`);
    duplicated.find('.research-output-abbreviation input').attr('name', `${duplicatedName}[abbreviation]`);
    duplicated.find('.research-output-abbreviation label').attr('for', `${duplicatedId}_abbreviation`);
    duplicated.find('.research-output-abbreviation input').val(null);
    // Research Output fullname
    duplicated.find('.research-output-fullname input').attr('id', `${duplicatedId}_fullname`);
    duplicated.find('.research-output-fullname input').attr('name', `${duplicatedName}[fullname]`);
    duplicated.find('.research-output-fullname label').attr('for', `${duplicatedId}_fullname`);
    duplicated.find('.research-output-fullname input').val(null);
    // Research Output pid
    duplicated.find('.research-output-pid input').attr('id', `${duplicatedId}_pid`);
    duplicated.find('.research-output-pid input').attr('name', `${duplicatedName}[pid]`);
    duplicated.find('.research-output-pid label').attr('for', `${duplicatedId}_pid`);
    duplicated.find('.research-output-pid input').val(null);
    // Research Output type
    duplicated.find('.research-output-type select').attr('id', `${duplicatedId}_research_output_type_id`);
    duplicated.find('.research-output-type select').attr('name', `${duplicatedName}[research_output_type_id]`);
    duplicated.find('.research-output-type label').attr('for', `${duplicatedId}_research_output_type_id`);
    duplicated.find('.research-output-type select').val(null);
    duplicated.find('.research-output-type select').trigger('change');

    duplicated.find('.research-output-other-type-label input').attr('id', `${duplicatedId}_other_type_label`);
    duplicated.find('.research-output-other-type-label input').attr('name', `${duplicatedName}[other_type_label]`);
    duplicated.find('.research-output-other-type-label label').attr('for', `${duplicatedId}_other_type_label`);
    duplicated.find('.research-output-other-type-label input').val(null);
    duplicated.find('.research-output-other-type-label').hide();


    // Research Output order
    duplicated.find('.research-output-order').attr('id', `${duplicatedId}_order`);
    duplicated.find('.research-output-order').attr('name', `${duplicatedName}[order]`);
    duplicated.find('.research-output-order').val(lastResearchOutputOrder + 1);

    duplicated.appendTo('#research-outputs');
    displayROInputs(duplicated);
    editElement.hide();
    cancelElement.hide();
    deleteElement.hide();
  });

  $('.research-output-type-select').change((e) => {
    const selectElement = $(e.target);
    const parentElement = selectElement.closest('.research-output-element');
    const otherTypeElement = parentElement.find('.research-output-other-type-label');
    if (selectElement.find('option:selected').data('other')) {
      otherTypeElement.prop('required', true);
      otherTypeElement.show();
    } else {
      otherTypeElement.prop('required', false);
      otherTypeElement.hide();
    }
  });

  $('#research-outputs').on('click', ' .research-output-actions .edit', (e) => {
    const editElement = $(e.target);
    const parentElement = $(e.target).closest('.research-output-element');
    displayROInputs(parentElement);

    editElement.hide();
  });
});
