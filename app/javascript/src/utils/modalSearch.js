$(() => {
  // Converts the custom item form contents into a selection result that will be passed during form submission
  const addCustomSelection = (resultsBlock, title, uri, description) => {
    const selectionsBlockId = resultsBlock.attr('id').replace('-results', '-selections');
    const context = resultsBlock.attr('id').replace('-results', '').replace('modal-search-', '');

    if (selectionsBlockId !== undefined && title.length > 0) {
      const selectionsBlock = $(`#${selectionsBlockId}`);
      const id = `999${Math.floor(Math.random() * 999)}`;
      const fieldId = `${context}_attributes_${id}`;
      const fieldName = `${context}_attributes[${id}]]`;

      const customItemBlock = $('<div class="modal-search-result col-md-12"/>');
      const link = `<a href="${uri}" target="_blank" class="has-new-window-popup-info">${uri}</a>`;
      const titleField = $(`<input type="hidden" id="${fieldId}_name" name="${fieldName}[name]" value="${title}"/>`);
      const descField = $(`<input type="hidden" id="${fieldId}_description" name="${fieldName}[description]" value="${description}"/>`);
      const uriField = $(`<input type="hidden" id="${fieldId}_uri" name="${fieldName}[uri]" value="${uri}"/>`);
      const removeButton = `
        <button class="modal-search-result-unselector" name="button" type="button"
                title="Click to remove ${title}">Remove</button>
      `;

      customItemBlock.append(`<div class="modal-search-result-label">${title} ${removeButton}</div>`)
                     .append(`<p>${description}</p>`)
                     .append(`<p><strong>Repository URL:</strong> ${link}</p>`)
                     .append(titleField)
                     .append(descField)
                     .append(uriField);

      selectionsBlock.append(customItemBlock);

      displayAlert(resultsBlock, title);
    }
  };

  // Returns whether or not the custom item form is valid and then displays the custom item form errors
  // block if it is invalid
  const validateCustomItem = (form) => {
    if (form.length > 0) {
      const nameField = form.find('.custom-item-title');
      const descrField = form.find('.custom-item-description');
      const uriField = form.find('.custom-item-uri');
      const errBlock = form.find('.custom-item-errors')

      if (nameField.length <= 0 || nameField.val().length <= 3 ||
          uriField.length < 0 || uriField.val().length <= 3 ||
          descrField.length < 0 || descrField.val().length <= 3) {
        errBlock.removeClass('hidden');
        return false;
      } else {
        errBlock.addClass('hidden');
        return true;
      }
    } else {
      return false;
    }
  };

  // Display a message to let the user know that the item was added (also reads an Aria alert)
  const displayAlert = (context, itemTitle) => {
    if (context.length > 0 && itemTitle.length > 0) {
      const alertBlock = context.closest('.modal-body').find('#item-selected-alert');
      if (alertBlock.length > 0) {
        alertBlock.text(`${itemTitle} has been added.`).fadeIn().delay(3000).fadeOut();
      }
    }
  };

  // Shows/Hides the custom item form
  const toggleCustomItemForm = (modalBody) => {
    if (modalBody.length > 0) {
      const filterBlock = modalBody.find('.modal-search-filters');
      const customBlock = modalBody.find('#add-custom-items');
      const resultsBlock = modalBody.find('.modal-search-results');

      if (customBlock.length > 0 && resultsBlock.length > 0) {
        if (customBlock.hasClass('hidden')) {
          customBlock.removeClass('hidden');
          filterBlock.addClass('hidden');
          resultsBlock.addClass('hidden');
        } else {
          customBlock.addClass('hidden');
          filterBlock.removeClass('hidden');
          resultsBlock.removeClass('hidden');
        }
      }
    }
  };

  // Add the selected item to the selections section
  $('body').on('click', 'button.modal-search-result-selector', (e) => {
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
            clone.find('.modal-search-result-selector').addClass('hidden');
            clone.find('.modal-search-result-unselector').removeClass('hidden');
            clone.find('.tags').remove();
            selectionsBlock.append(clone);
            selectedBlock.remove();

            displayAlert(resultsBlock, 'Item');
          }
        }
      }
    }
  });

  // Remove the selected item
  $('body').on('click', 'button.modal-search-result-unselector', (e) => {
    e.preventDefault();
    const selection = $(e.target).closest('.modal-search-result');

    if (selection.length > 0) {
      selection.remove();
    }
  });

  // Display/hide the custom item form
  $('body').on('click', '.toggle-custom-items', (e) => {
    e.preventDefault();
    const modalBody = $(e.target).closest('.modal-body');

    if (modalBody.length > 0) {
      toggleCustomItemForm(modalBody);
    }
  });

  // Convert the custom item entry into a selection and then hide the form
  $('body').on('click', '.custom-item-button', (e) => {
    const form = $(e.target).closest('form');

    if (form.length > 0 && validateCustomItem(form)) {
      const modalBody = form.closest('.modal-body');

      if (modalBody.length > 0) {
        const resultsBlock = modalBody.find('.modal-search-results');
        const title = form.find('.custom-item-title').val();
        const uri = form.find('.custom-item-uri').val();
        const description = form.find('.custom-item-description').val();

        if (title.length >= 3 && uri.length >= 3) {
          addCustomSelection(resultsBlock, title, uri, description);
          toggleCustomItemForm(modalBody);
        }
      }
    }
    e.preventDefault();
  });
});
