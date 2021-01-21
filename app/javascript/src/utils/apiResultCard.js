import getConstant from './constants';

//
//
$(() => {
  // Toggles the External Api search area
  const toggleSearchBlock = (context) => {
    if (context.length > 0) {
      const selectionBlock = context.closest('.external-api-selection-block');

      if (selectionBlock.length > 0) {
        const searchBlock = selectionBlock.find('.external-api-search-block');

        if (searchBlock.length > 0) {
          if (searchBlock.hasClass('hidden')) {
            searchBlock.removeClass('hidden');
          } else {
            searchBlock.addClass('hidden');
          }
        }
      }
    }
  };

  // Cancels the press of the Enter/Return key within the search box so that it
  // does not submit the parent form but instead sets focus on the 'Search' button
  // which triggers the autocomplete's change event and calls the controller action.
  $('body').on('keypress', '.external-api-search-block .autocomplete', (e) => {
    const code = (e.keyCode || e.which);
    if (code === 13) {
      e.preventDefault();
      $(e.target).closest('.form-group').find('.external-api-faux-search-button').focus();
    }
  });

  // The faux button is just there to allow the search box and filter controls
  // to 'update' and trigger the data-remote UJS call to the controller
  $('body').on('click', '.external-api-faux-search-button', (e) => {
    e.preventDefault();
  });

  // Expands/Collapses the external api card's 'More info'/'Less info' section
  $('body').on('click', '.external-api-result-card .more-info a.more-info-link', (e) => {
    e.preventDefault();
    const link = $(e.target);

    if (link.length > 0) {
      const info = $(link).siblings('div.info');

      if (info.length > 0) {
        if (info.hasClass('hidden')) {
          info.removeClass('hidden');
          link.text(`${getConstant('LESS_INFO')}`);
        } else {
          info.addClass('hidden');
          link.text(`${getConstant('MORE_INFO')}`);
        }
      }
    }
  });

  // Put the facet text into the search box
  $('body').on('click', '.external-api-result-card a.facet', (e) => {
    const link = $(e.target);

    if (link.length > 0) {
      const textField = link.closest('.modal-body').find('input.autocomplete');

      if (textField.length > 0) {
        textField.val(link.text());
      }
    }
  });

  // Toggle the External API search area when the user clicks the 'Add %{topic}' button or 'X' close button
  $('body').on('click', '.external-api-expand-search, .external-api-collapse-search', (e) => {
    e.preventDefault();
    const link = $(e.target);
    toggleSearchBlock(link);
  });

  // Add the selected repository
  $('body').on('click', '.external-api-selection a.external-api-result-selector', (e) => {
    e.preventDefault();
    const modal = $(e.target).closest('.external-api-search-modal');

    if (modal.length > 0) {
      const externalApi = modal.attr('external_api');
      const context = $(`.external-api-selection[external_api="${externalApi}"]`);
      const selections = context.find('.external-api-selections');
      const card = $(e.target).closest('.external-api-result-card');

      if (selections.length > 0 && card.length > 0) {
        const clone = card.clone();
        clone.find('.external-api-result-selector').addClass('hidden');
        clone.find('.external-api-result-unselector').removeClass('hidden');
        clone.find('.tags').addClass('hidden');
        selections.siblings('.no-selection').addClass('hidden');
        selections.html(clone);
      }
    }
  });

  // Remove the selected repository
  $('body').on('click', 'a.external-api-result-unselector', (e) => {
    e.preventDefault();
    const card = $(e.target).closest('.external-api-result-card');

    if (card.length > 0) {
      card.parent().find('.no-selection').removeClass('hidden');
      card.remove();
    }
  });

});
