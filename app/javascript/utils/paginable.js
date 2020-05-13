
export const paginableSelector = '.paginable';

$(() => {
  const onAjaxSuccessHandler = (e, data) => {
    $(e.target).closest(paginableSelector).replaceWith($(data));
  };
  // Event listener for Ajax success event captured in response to a paginable link clicked or
  // search form submitted. Note the presence of a selector for on (e.g. a[data-remote="true"])
  // so that descendant elements from .paginable-results that are added in future are also
  // automatically handled.
  $('body').on('ajax:success',
    'form.paginable-action[data-remote="true"], a.paginable-action[data-remote="true"]',
    onAjaxSuccessHandler);
});

export { paginableSelector as default };
