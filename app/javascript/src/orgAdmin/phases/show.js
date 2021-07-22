import 'jquery-ui/sortable';
import { renderAlert } from '../../utils/notificationHelper';

$(() => {
  // Is there already one prefix section on this Phase?
  //
  // draggableSections - A jQuery object, the sortable element.
  //
  // Returns Boolean
  function prefixSectionExists(draggableSections) {
    // Collect an Array of the .section-group id attributes (the unmodifiable sections are
    // in a block called '#baseline-sections'.
    const ids = [];
    draggableSections.find('.section-group').each((_i, e) => {
      // Sortable adds an element within this with a blank id
      if (e.id.trim() !== '') { ids.push(e.id); }
    });
    // If the index of the baseline section is greater than 1, we have too many prefixes.
    return ids.indexOf('baseline-sections') > 1;
  }

  // Does the page have any unmodifiable sections (Do we need to police ordering?)
  //
  // Returns Boolean
  function hasUnmodifiableSections() {
    return $('[data-modifiable=false]').length > 0;
  }

  // Initialize the draggable-sections element as a jQuery sortable.
  // Read the docs here for more info: http://api.jqueryui.com/sortable/
  $('.draggable-sections').sortable({
    handle: 'i.fa-arrows-alt',
    axis: 'y',
    cursor: 'move',
    // Remove the placeholder object from the DOM once the item has been placed
    receive(event, ui) { ui.placeholder.remove(); },
    beforeStop() {
      if (hasUnmodifiableSections() && prefixSectionExists($(this))) {
        // Prevent the sort action from completing. Moves element back to source
        $(this).sortable('cancel');
        renderAlert(`You can only place one section before the funder template.
          Multiple can go afterwards.`, {
          floating: true, autoDismiss: true,
        });
      }
    },
    update() {
      // Collect the section-id from each section element on the page.
      const sectionIds = $('.section[data-section-id]')
        .map((i, element) => $(element).data('section-id')).toArray();

      // Post the section IDs to the server in their new order on the page.
      $.rails.ajax({
        url: $(this).data('url'),
        type: 'post',
        data: $.param({ 'phase[sort_order]': sectionIds }),
      });
    },
  });
});
