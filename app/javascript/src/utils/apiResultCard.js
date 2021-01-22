import getConstant from './constants';

//
//
$(() => {

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

  // Put the facet text into the search box when the user clicks on one
  $('body').on('click', '.external-api-result-card a.facet', (e) => {
    const link = $(e.target);

    if (link.length > 0) {
      const textField = link.closest('.modal-body').find('input.autocomplete');

      if (textField.length > 0) {
        textField.val(link.text());
      }
    }
  });

  // Add the selected repository
  $('body').on('click', 'a.external-api-result-selector', (e) => {
    e.preventDefault();
    const link = $(e.target);

    if (link.length > 0) {
      const result = $(e.target).closest('.external-api-result-card');

      if (result.length > 0) {
        const dataType = result.attr('data-type');

        if (dataType !== undefined) {
          const selectionBlock = $(`.external_api_selected_results-${dataType} .external-api-selections`);

          if (selectionBlock.length > 0) {
            const clone = result.clone();
            clone.find('.external-api-result-selector').addClass('hidden');
            clone.find('.external-api-result-unselector').removeClass('hidden');
            clone.find('.external-api-result-selector').addClass('hidden');
            selectionBlock.append(clone);
            result.remove();
          }
        }
      }
    }
  });

  // Remove the selected repository
  $('body').on('click', 'a.external-api-result-unselector', (e) => {
    e.preventDefault();
    const selection = $(e.target).closest('.external-api-result-card');

    if (selection.length > 0) {
      selection.remove();
    }
  });

});
