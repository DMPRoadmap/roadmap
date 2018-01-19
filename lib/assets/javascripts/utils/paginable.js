import { isValidText } from './isValidInputType';

export const paginableSelector = '.paginable';

$(() => {
  const onAjaxSuccessHandler = (e, data) => {
    // Note we update ONLY .paginable-results container although the AJAX response
    // returns the entire paginable layout html. That permits, keeping any value entered
    // in the search box (if any)
    $(e.target).closest(paginableSelector).find('.paginable-results').html($(data).find('.paginable-results').children());
  };
  $('.paginable-search form[data-remote="true"]').on('ajax:before', e => isValidText($(e.target).find('input[name="search"]').val()));
  $('.paginable-results').on('ajax:before', (e) => {
    const target = $(e.target);
    if (target.hasClass('clear')) {
      // Clears out search box when clear link was triggered
      $(e.target).closest(paginableSelector).find('.paginable-search input[name="search"]').val('');
    }
  });
  // Event listener for Ajax success event in response to search button clicked
  $('.paginable-search').on('ajax:success', 'form[data-remote="true"]', onAjaxSuccessHandler);
  // Event listener for Ajax success event captured in response to a paginable link clicked.
  // Note the presence of a selector for on (e.g. a[data-remote="true"]) so that descendant elements
  // from .paginable-results that are added in future are also automatically handled.
  $('.paginable-results').on('ajax:success', 'a[data-remote="true"]', onAjaxSuccessHandler);
});

export { paginableSelector as default };
