$(() => {
  // Add the selected item to the selections section
  $('body').on('click', 'a.modal-search-result-selector', (e) => {
    e.preventDefault();
    const link = $(e.target);

    if (link.length > 0) {
      const selectedBlock = $(e.target).closest('.modal-search-result');
      const resultsBlock = $(e.target).closest('.modal-search-results');

      if (resultsBlock.length > 0 && selectedBlock.length > 0) {
        const selectionsBlockId = resultsBlock.attr('id').replace('-results', '-selections');

        if (selectionsBlockId !== undefined) {
          const selectionsBlock = $(`#${selectionsBlockId}`);

          if (selectionsBlock.length > 0) {
            const clone = selectedBlock.clone();
            clone.find('.modal-search-result-selector').addClass('d-none');
            clone.find('.modal-search-result-unselector').removeClass('d-none');
            clone.find('.tags').remove();
            selectionsBlock.append(clone);
            selectedBlock.remove();
          }
        }
      }
    }
  });

  // Remove the selected item
  $('body').on('click', 'a.modal-search-result-unselector', (e) => {
    e.preventDefault();
    const selection = $(e.target).closest('.modal-search-result');

    if (selection.length > 0) {
      selection.remove();
    }
  });
});
