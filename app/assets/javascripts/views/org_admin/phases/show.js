import 'jquery-ui/ui/widgets/sortable';
import { renderAlert } from '../../../utils/notificationHelper';

$(() => {
  // Is there already one prefix section on this Phase?
  //
  // draggableSections - A jQuery object, the sortable element.
  //
  // Returns Boolean
  function prefixSectionExists(draggableSections) {
    // How many sections are there?
    const numberOfSections = draggableSections.has('.panel.section').length;
    // How many modifiable sections are there?
    const modifiableSections = draggableSections.has('[data-modifiable=true]').length;
    // If all sections are modifiable, return false;
    if (numberOfSections == modifiableSections) {
      return false;
    }
    ////
    // Assuming all sections are NOT modifiable...

    // A boolean to check if there a modifible prefix Section
    const firS = draggableSections.has('[data-modifiable=true]:nth-child(1)').length == 1;

    // A boolean to check if there's a second prefix Section (this is invalid!)
    const secS = draggableSections.has('[data-modifiable=true]:nth-child(2)').length == 1;

    if (firS && secS) {
      return true;
    } else {
      return false;
    }
  }

  // Initialize the draggable-sections element as a jQuery sortable.
  // Read the docs here for more info: http://api.jqueryui.com/sortable/
  $('.draggable-sections').sortable({
    handle: 'i.fa-arrows',
    axis: 'y',
    cursor: 'move',
    beforeStop() {
      if (prefixSectionExists($(this))) {
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
        method: 'post',
        data: { sort_order: sectionIds },
      });
    },
  });
});
