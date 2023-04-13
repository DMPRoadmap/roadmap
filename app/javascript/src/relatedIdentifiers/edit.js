// JS to handle the '+ Add a related work' link
$(() => {
  const relatedIdentifierBlock = $('.related-works');

  if (relatedIdentifierBlock.length > 0) {
    const addRowButton = relatedIdentifierBlock.siblings('.add-related-work').find('button');
    const saveButton = $('.related-works-save-btn');

    // Replace the unique record identifier on the :id and :for attributes
    const replaceId = (element, id) => {
      const regExp = /_[0-9]+_/;
      if (element.attr('for')) {
        element.attr('for', element.attr('for').replace(regExp, `_${id}_`));
      } else {
        element.attr('id', element.attr('id').replace(regExp, `_${id}_`));
      }
    };

    // Replace the unique record identifier on the :name attributes
    const replaceName = (element, id) => {
      const regExp = /\[[0-9]\]\[/;
      if (element.attr('name')) {
        element.attr('name', element.attr('name').replace(regExp, `[${id}][`));
      }
    };

    // Replace the unique record identifier for each label and input/select
    const replaceIdsAndNames = (row, id) => {
      row.find('label').each((_idx, label) => {
        replaceId($(label), id);
      });
      row.find('input, select').each((_idx, field) => {
        replaceId($(field), id);
        replaceName($(field), id);
      });
    };

    const addNewRow = () => {
      // Find the hidden empty row which will be used to clone the new row
      const emptyRow = relatedIdentifierBlock.find('.related-work-row.hidden');
      if (emptyRow.length > 0) {
        const newRow = emptyRow.clone();

        // Set the the new row's id
        replaceIdsAndNames(newRow, new Date().getTime());

        newRow.removeClass('hidden');
        saveButton.removeClass('hidden');
        relatedIdentifierBlock.append(newRow[0].outerHTML);
      }
    };

    // Add a new row if the user clicks the 'Link a research output' button
    if (addRowButton.length > 0) {
      addRowButton.on('click', (e) => {
        e.preventDefault();
        addNewRow();
      });
    }

    // Remove the entire row if the user clicks the 'X' delete link
    relatedIdentifierBlock.on('click', '.remove-related-work', (e) => {
      e.preventDefault();
      citationRow = $(e.target).closest('.citation');

      if (citationRow.length > 0) {
        citationRow.remove();
      } else {
        $(e.target).closest('.related-work-row').remove();
      }

      if (relatedIdentifierBlock.find('.related-work-row').length <= 1 &&
          relatedIdentifierBlock.find('.citation').length <= 0) {
        // saveButton.addClass('hidden');
      }
    });
  }
});
