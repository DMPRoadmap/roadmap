import 'bootstrap-sass/assets/javascripts/bootstrap.min';

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
 * Your accordion should follow the Boostrap 3.x layout:
 * ------------------------------------------------------------
 *    <div id="accordion" class="panel-group" role="tablist" aria-multiselectable="true">
 *      <div class="panel panel-default">
 *        <div class="panel-heading" role="tab" id="headingA">
 *          <h2 class="panel-title">
 *            <a role="button" data-toggle="collapse" data-parent="accordion"
 *                   href="#collapseA" aria-controls="collapseA" aria-expanded="false">
 *              Section A
 *            </a>
 *          </h2>
 *        </div>
 *        <div id="collapseA" class="panel-collapse collapse" role="tabpanel"
 *          aria-labelledby="headingA">
 *          <div class="panel-body">
 *            This is test section A.
 *          </div>
 *        </div>
 *      </div>
 *    </div>
 */
export default () => {
  $('.accordion-controls').on('click', (e) => {
    e.preventDefault();
    const currentTarget = $(e.currentTarget);
    const target = $(e.target);
    const direction = target.attr('data-toggle-direction');
    if (direction) {
      // Selects all .panel elements where the parent is currentTarget.attr('data-parent') and
      // after gets the immediately children whose class selector is panel-collapse
      $(`#${currentTarget.attr('data-parent')} > .panel`).children('.panel-collapse').each((i, el) => {
        const panelCollapse = $(el);
        // Expands or collapses the panel according to the
        // direction passed (e.g. show --> expands, hide --> collapses)
        if (direction === 'show') {
          if (!panelCollapse.hasClass('in')) {
            panelCollapse.prev().trigger('click');
          }
        } else {
          panelCollapse.collapse(direction);
        }
        // Sets icon at panel-title accordingly
        panelCollapse.prev().find('i.fa')
          .removeClass('fa-plus fa-minus').addClass(direction === 'show' ? 'fa-minus' : 'fa-plus');
      });
    }
  });
};
