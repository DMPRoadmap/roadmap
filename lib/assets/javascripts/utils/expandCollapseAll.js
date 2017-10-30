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
 *      </div>
 *      <div id="collapseA" class="panel-collapse collapse" role="tabpanel"
 *                  aria-labelledby="headingA">
 *        <div class="panel-body">
 *          This is test section A.
 *        </div>
 *      </div>
 *    </div>
 *  </div>
 */
export default () => {
  $.each($('.accordion-controls'), (idx, el) => {
    const accordion = $(el).attr('data-parent');

    $.each($(el).children('a[data-toggle-direction]'), (i, a) => {
      $(a).click((event) => {
        event.preventDefault();
        $(`#${accordion}`).children('div.panel-collapse').collapse(`${$(a).attr('data-toggle-direction')}`);
      });
    });
  });
};
