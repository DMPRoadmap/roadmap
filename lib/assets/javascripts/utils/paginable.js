import { isValidText } from './isValidInputType';

export const paginableSelector = '.paginable';

$(() => {
  const onAjaxSuccessHandler = (e, data) => {
    $(e.target).closest(paginableSelector).html($(data));
    // Rewire ajax handlers for newly rendered table
    $(paginableSelector).find('.paginable-controls').on('ajax:success', 'a[data-remote="true"]', onAjaxSuccessHandler);
    $(paginableSelector).find('.paginable-search').on('ajax:success', 'form[data-remote="true"]', onAjaxSuccessHandler);
  };
  $('.paginable-search form[data-remote="true"]').on('ajax:before', e => isValidText($(e.target).find('input[name="search"]').val()));
  // Event listener for Ajax success event captured in response to a paginable link clicked or
  // search form submitted. Note the presence of a selector for on (e.g. a[data-remote="true"])
  // so that descendant elements from .paginable-results that are added in future are also
  // automatically handled.
  $(paginableSelector).find('.paginable-controls').on('ajax:success', 'a[data-remote="true"]', onAjaxSuccessHandler);
  $(paginableSelector).find('.paginable-search').on('ajax:success', 'form[data-remote="true"]', onAjaxSuccessHandler);
});

export { paginableSelector as default };
