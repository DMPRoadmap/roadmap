import { isValidText } from './isValidInputType';

$(() => {
  const onAjaxSuccessHandler = (e, data) => {
    $(e.target).closest('.paginable').find('.paginable-results').html($(data).find('.paginable-results').children());
  };
  $('.paginable-search form[data-remote="true"]').on('ajax:before', e => isValidText($(e.target).find('input[name="search"]').val()));
  $('.paginable-results').on('ajax:before', (e) => {
    const target = $(e.target);
    if (target.hasClass('view-all')) {
      // Clears out search box when view-all link was triggered
      $(e.target).closest('.paginable').find('.paginable-search input[name="search"]').val('');
    }
  });
  // Event listener for Ajax success event in response to search button clicked
  $('.paginable-search form[data-remote="true"]').on('ajax:success', '', onAjaxSuccessHandler);
  // Event listener for Ajax success event captured in response to a paginable link clicked.
  // Note the presence of a selector for on (e.g. a[data-remote="true"]) so that descendant elements
  // from .paginable-results that are added in future are also automatically handled.
  $('.paginable-results').on('ajax:success', 'a[data-remote="true"]', onAjaxSuccessHandler);
});
