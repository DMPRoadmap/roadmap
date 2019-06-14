
$(() => {
  $('#datasets').sortable({
    handle: '.dataset-actions .handle',
    stop: () => {
      $('#datasets .dataset-element').each(function callback(index) {
        $(this).find('.dataset-order').val(index + 1);
      });
    },
  });

  $('#add-dataset').click(() => {
    const lastDataset = $('#datasets .dataset-element').last();
    const lastDatasetOrder = parseInt(lastDataset.find('.dataset-order').val(), 10);
    const duplicated = lastDataset.clone(false, false);
    const duplicatedId = `plan_datasets_attributes_${new Date().getTime()}`;
    const duplicatedName = `plan[datasets_attributes][${new Date().getTime()}]`;

    // Dataset name
    duplicated.find('.dataset-name input').attr('id', `${duplicatedId}_name`);
    duplicated.find('.dataset-name input').attr('name', `${duplicatedName}[name]`);
    duplicated.find('.dataset-name label').attr('for', `${duplicatedId}_name`);
    duplicated.find('.dataset-name input').val(null);
    // Dataset description
    duplicated.find('.dataset-description input').attr('id', `${duplicatedId}_description`);
    duplicated.find('.dataset-description input').attr('name', `${duplicatedName}[description]`);
    duplicated.find('.dataset-description label').attr('for', `${duplicatedId}_description`);
    duplicated.find('.dataset-description input').val(null);
    // Dataset order
    duplicated.find('.dataset-order').attr('id', `${duplicatedId}_order`);
    duplicated.find('.dataset-order').attr('name', `${duplicatedName}[order]`);
    duplicated.find('.dataset-order').val(lastDatasetOrder + 1);

    duplicated.appendTo('#datasets');
  });
});
