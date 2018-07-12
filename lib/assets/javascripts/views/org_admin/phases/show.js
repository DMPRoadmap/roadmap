import 'jquery-ui-dist/jquery-ui';

$(() => {
  // Is there already one prefix section on this Phase?
  //
  // draggableSections - A jQuery object, the sortable element.
  //
  // Returns Boolean
  function prefixSectionExists(draggableSections) {
    return !!draggableSections
      .has('[data-modifiable=true]:nth-child(1)').length &&
      !!draggableSections.has('[data-modifiable=true]:nth-child(2)').length
  }

  // Initialize the draggable-sections element as a jQuery sortable.
  // Read the docs here for more info: http://api.jqueryui.com/sortable/
  $('.draggable-sections').sortable({
    handle: 'i.fa-bars',
    axis: 'y',
    cursor: 'move',
    beforeStop() {
      if (prefixSectionExists($(this))) {
        // Prevent the sort action from completing. Moves element back to source
        $(this).sortable('cancel');
        // Display a wobble effec to signify error
        $(this).effect('shake');
      }
    },
    update() {
      // Collect the section-id from each section element on the page.
      const sectionIds = $('.section[data-section-id]')
        .map((i, element) => $(element).data('section-id')).toArray();

      // Post the section IDs to the server in their new order on the page.
      $.rails.ajax({
        url: $(this).data('url'),
        method: 'post',
        data: { sort_order: sectionIds },
      });
    },
  });
});
