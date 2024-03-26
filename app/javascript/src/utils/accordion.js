/*
 * This method expects an expand/collapse all link to be contained within a div with
 * the '.accordion-controls' class. The div container should have a 'data-parent' that
 * corresponds with the id of your accordion container. The links should have a
 * 'data-toggle-direction' attribute that contains either 'show' or 'hide'.
 * ------------------------------------------------------------
 *    <div class="accordion-controls" data-parent="accordion">
 *      <a href="#" data-toggle-direction="show"><%= _('expand all') %></a>
 *      <a href="#" data-toggle-direction="hide"><%= _('collapse all') %></a>
 *    </div>
 *
 * Your accordion should follow the Boostrap 5.x layout:
 * ------------------------------------------------------------
n*
 *  <div class="accordion" id="accordionDefault">
 *
 *    <div class="accordion-item">
 *      <h2 class="accordion-header" id="headingDefaultOne">
 *        <button
 *          class="accordion-button"
 *          type="button"
 *          data-bs-toggle="collapse"
 *          data-bs-target="#collapseDefaultOne"
 *          aria-expanded="false"
 *          aria-controls="collapseDefaultOne"
 *        >
 *          Accordion Item #1
 *        </button>
 *      </h2>
 *
 *      <div
 *        id="collapseDefaultOne"
 *        class="accordion-collapse collapse show"
 *        aria-labelledby="headingDefaultOne"
 *        data-bs-parent="#accordionDefault"
 *      >
 *        <div class="accordion-body">
 *          Accordion Body #1
 *        </div>
 *      </div>
 *
 *    </div>
 *
 *    <div class="accordion-item">
 *      <h2 class="accordion-header" id="headingDefaultTwo">
 *        <button
 *          class="accordion-button collapsed"
 *          type="button"
 *          data-bs-toggle="collapse"
 *          data-bs-target="#collapseDefaultTwo"
 *          aria-expanded="false"
 *          aria-controls="collapseDefaultTwo"
 *        >
 *          Accordion Item #2
 *        </button>
 *      </h2>
 *
 *      <div
 *        id="collapseDefaultTwo"
 *        class="accordion-collapse collapse"
 *        aria-labelledby="headingDefaultTwo"
 *        data-bs-parent="#accordionDefault"
 *      >
 *        <div class="accordion-body">
 *          Accordion Body #2
 *        </div>
 *      </div>
 *
 *    </div>
 *
 *    <div class="accordion-item">
 *      <h2 class="accordion-header" id="headingDefaultThree">
 *        <button
 *          class="accordion-button collapsed"
 *          type="button"
 *          data-bs-toggle="collapse"
 *          data-bs-target="#collapseDefaultThree"
 *          aria-expanded="false"
 *          aria-controls="collapseDefaultThree"
 *        >
 *          Accordion Item #3
 *        </button>
 *      </h2>
 *
 *      <div
 *        id="collapseDefaultThree"
 *        class="accordion-collapse collapse"
 *        aria-labelledby="headingDefaultThree"
 *        data-bs-parent="#accordionDefault"
 *      >
 *        <div class="accordion-body">
 *          Accordion Body #3
 *        </div>
 *      </div>
 *
 *    </div>
 *
 *  </div>
 *
 */

$(() => $('body').on('click', '.accordion-controls a[data-toggle-direction]', (e) => {
  e.preventDefault();
  const currentTarget = $(e.currentTarget);
  const target = $(e.target);
  const direction = target.attr('data-toggle-direction');
  const parentTargetName = currentTarget.parent().attr('data-parent');

  if (direction) {
    // Selects all .accordion-item elements where the parent is
    // currentTarget.attr('data-parent') and
    // after gets the immediate children whose class selector is accordion-item
    const parentTarget = $(`#${parentTargetName}`).length ? $(`#${parentTargetName}`) : $(`.${parentTargetName}`);
    parentTarget.children('.accordion-item').each((i, el) => {
      // We use $() to get Jquery HTML element from native Dom element
      const accordionItem = $(el);
      // Not these are Jquery HTML elements, again using $()
      const accordionHeader = $(accordionItem.children('.accordion-header').get(0));
      const accordionButton = $(accordionHeader.children('.accordion-button').get(0));
      const accordionCollapse = $(accordionItem.children('.accordion-collapse').get(0));
      // Expands or collapses according to the
      // direction passed (e.g. show --> expands, hide --> collapses)
      if (direction === 'show') {
        // To check if element with class .accordion-body has attribute data-loaded
        // we use the native Dom element so we can use hasAttribute()
        // and getAttribute() methods.
        const accordionBodyNativeDomEl = accordionCollapse.children('.accordion-body').get(0);
        if (accordionBodyNativeDomEl.hasAttribute('data-loaded')
          && accordionBodyNativeDomEl.getAttribute('data-loaded') === 'false') {
          // We need the native om element of the button to
          // to trigger click as the jquery trigger('click')
          // does not work for rails-ujs
          const accordionButtonNativeDomEl = accordionHeader.children('.accordion-button').get(0);
          accordionButtonNativeDomEl.click();
        }
        accordionButton.removeClass('collapsed');
        accordionCollapse.addClass('show');
      }

      if (direction === 'hide') {
        accordionButton.addClass('collapsed');
        accordionCollapse.removeClass('show');
      }
    });
  }
}));
