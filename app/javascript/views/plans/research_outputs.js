
$(() => {
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
    const duplicated = lastResearchOutput.clone(false, false);
    const duplicatedId = `plan_research_outputs_attributes_${new Date().getTime()}`;
    const duplicatedName = `plan[research_outputs_attributes][${new Date().getTime()}]`;

    // Research Output name
    duplicated.find('.research-output-name input').attr('id', `${duplicatedId}_name`);
    duplicated.find('.research-output-name input').attr('name', `${duplicatedName}[name]`);
    duplicated.find('.research-output-name label').attr('for', `${duplicatedId}_name`);
    duplicated.find('.research-output-name input').val(null);
    // Research Output description
    duplicated.find('.research-output-description input').attr('id', `${duplicatedId}_description`);
    duplicated.find('.research-output-description input').attr('name', `${duplicatedName}[description]`);
    duplicated.find('.research-output-description label').attr('for', `${duplicatedId}_description`);
    duplicated.find('.research-output-description input').val(null);
    // Research Output order
    duplicated.find('.research-output-order').attr('id', `${duplicatedId}_order`);
    duplicated.find('.research-output-order').attr('name', `${duplicatedName}[order]`);
    duplicated.find('.research-output-order').val(lastResearchOutputOrder + 1);

    duplicated.appendTo('#research-outputs');
  });
});
