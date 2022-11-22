import toggleSpinner from '../../utils/spinner';
import getConstant from '../../utils/constants';

// JS for the Public Plans page
$(() => {
  const publicPlansFacetingBlock = $('.t-publicplans__plans');
  const publicPlansContentHeader = $('.t-publicplans__section-header');

  const setFacetingMessage = (form) => {
    if (form.length > 0) {
      const messageBlock = form.find('.c-clear__applied');
      const selections = form.find('.js-facet__list input[type="checkbox"]:checked');
      let msg = getConstant('NO_FACETS_SELECTED');

      if (selections.length > 1) {
        msg = getConstant('MULTIPLE_FACETS_SELECTED').replace('%<nbr>s', selections.length);
      } else if (selections.length === 1) {
        msg = getConstant('ONE_FACET_SELECTED');
      }
      messageBlock.text(msg);
    }
  };

  if (publicPlansContentHeader && publicPlansFacetingBlock) {
    const sortSelect = $('#sort-select');
    const form = $(`#${sortSelect.attr('form')}`);

    if (form) {
      // Display the spinner whenever the form is submitted to let the user know its working
      form.on('submit', () => {
        toggleSpinner(true);
      });

      // User has changed the sort option
      sortSelect.on('change', () => {
        form.trigger('submit');
      });

      // User has cleared the search term
      form.on('click', '.js-search-clear', () => {
        form.find('#search').val('');
        form.trigger('submit');
      });

      // User clicked on a facet
      form.on('click', '.js-facet__list input[type="checkbox"]', () => {
        setFacetingMessage(form);
        form.trigger('submit');
      });

      // User has cleared the facets
      form.on('click', '.js-facet-clear', () => {
        form.find('.js-facet__list input[type="checkbox"]:checked').attr('checked', false);
        setFacetingMessage(form);
        form.trigger('submit');
      });

      setFacetingMessage(form);
    }
  }
});
