# Modal Search

This modal search allows your user to search for something, select the results they want and then places those selections on your form so that they are part of the form submission.

To add it to your page, you must render 2 partials:
1. The first adds a 'selected results' section to your form.
2. The second adds the modal dialog which should be placed #outside# of your form, typically at the bottom of the page.

You must also define the following:
1. Determine a namespace to use that will be unique on your page. You can add multiple modal searches to your page. Using a unique namespace allows the JS to properly manage this functionality.
2. A controller action to perform a search. You will specify this path and method when rendering the modal partial.
3. A `js.erb` that will use the namespace to replace the `modal-search-[namespace]-results` section of the modal window.
4. A partial that defines how an individual result should be displayed. The display of a search result is up to you, this partial will be used in the modal search results section as well as the selected results section. The 'Select' and 'Remove' links will be managed by the modal search code.
5. (Optional) A partial that contains additional filter/search options. The modal search contains a 'search term' box. You can define additional facets/filters as needed.

## Define an area to display selections

As noted above, you must add a call to render the `layouts/modal_search/selections` partial. This should live within your form element so that any selections the user makes within the modal search window are passed back to the server upon form submission. See `views/research_outputs/_form.html.erb` for an example of rendering this section and `controllers/research_outputs_controller.rb` (and `models/research_output.rb`) for an example of how to process the user's selections.

The contents of this section will be populated by the JS in `app/javascript/src/utils/modalSearch.js` when a user clicks on the 'Select' link next to item's title/name. Once the item appears in this section, a 'Remove' link will appear that allows the user to remove it from this section.

Example screenshot of selected repositories:
![Screenshot of some repositories selected via a modal search](../../../../docs/screenshots/modal_selections.png)

Example render of this section:
```ruby
var resultsDiv = $('#modal-search-repositories-results');

resultsDiv.html('<%=
  escape_javascript(
    render(
      partial: "layouts/modal_search/selections",
      locals: {
        namespace: "repositories",
        button_label: _("Add a repository"),
        item_name_attr: :name,
        results: research_output.repositories,
        selected: true,
        result_partial: "research_outputs/repositories/search_result",
        search_path: repository_search_plan_path(research_output.plan),
        search_method: :get
      }
    )
  ) %>');
```

Locals:
- #namespace# - a unique name to identify the modal. This value can be used to match a selected result to a section of the parent page.
- #button_label# - the text for the button that opens the modal search window
- #item_name_attr# - The attribute that contains the title/name of the item.
- #results# - any currently selected items
- #selected# - this should be 'true' here. This will ensure that the 'Remove' link gets displayed for the selected items contained in the results.
- #result_partial# - The partial you have defined to display the item's info
- #search_path# - the path to controller endpoint that will perform the search
- #search_method# - the http method used to perform the search

## Define the modal dialog

This should be placed outside any form elements you may have defined on your page because it uses its own form element to process the search.

To add the modal search to your page you must render the form partial. For example:
```ruby
<%= render partial: "layouts/modal_search/form",
           locals: {
             namespace: "repositories",
             label: "Repository",
             search_examples: "(e.g. DNA, titanium, FAIR, etc.)",
             model_instance: research_output,
             search_path: repository_search_plan_path(research_output.plan),
             search_method: :get
           } %>
```

Locals:
- #namespace# - a unique name to identify the modal. This value can be used to match a selected result to a section of the parent page.
- #label# - the text to display on the modal window. This will be swapped in so that it reads: '[label] search'
- #search_examples# - Helpful text that will appear in the search term box as a placeholder to givethe user some suggestions.
- #model_instance# - An instance of the parent object that the search results will be associated to. (e.g. an instance of ResearchOutput if the user will be searching for a license or repository). This is used to help define the `form_with` on the modal search form.
- #search_path# - the path to controller endpoint that will perform the search
- #search_method# - the http method used to perform the search

Example of the modal window:
![Screenshot of the modal search dialog for repositories](../../../../docs/screenshots/modal_search.png)

Note that the 'search term' text field box is added by default. The two select boxes are custom filters. See below for info on defining custom filters.

Once the user clicks the search button, your controller/action will be called and the `layouts/modal_search/results` partial will be rendered by your `js.erb`. The results will be paginated, so be sure to include `.page(params[:page])`in your controller!

Example of the `js.erb`:

For example:
```ruby
var resultsDiv = $('#modal-search-repositories-results');

resultsDiv.html('<%=
  escape_javascript(
    render(
      partial: "layouts/modal_search/results",
      locals: {
        namespace: "repositories",
        results: @search_results,
        selected: false,
        item_name_attr: :name,
        result_partial: "research_outputs/repositories/search_result",
        search_path: repository_search_plan_path(@plan),
        search_method: :get
      }
    )
  ) %>');
```

Locals:
- #namespace# - a unique name to identify the modal. This value can be used to match a selected result to a section of the parent page.
- #results# - any currently selected items
- #selected# - this should be 'false' here. This will ensure that the 'Select' link and pagination controls are displayed.
- #item_name_attr# - The attribute that contains the title/name of the item.
- #result_partial# - The partial you have defined to display the item's info
- #search_path# - the path to controller endpoint that will perform the search.
- #search_method# - the http method used to perform the search

As the user selects results, the JS will move the result from the modal window to the selections sections described above.

Note that the modal_search results can work with either an ActiveRecord Model or a Hash!

## Adding additional search criteria

By default the modal search will only display the 'search term' text field and an 'Apply filters' button. You can add additional custom filters by supplying content to `yield :filters`. In the screenshot above, you can see 2 additional select boxes that allow the user to further refine the search.

Example definition of the :filters content:
```ruby
<% content_for :filters do %>
  <%
  by_type_tooltip = _("Refine your search to discipline specific, institutional or generalist repositories.")
  by_subject_tooltip = _("Select a subject area to refine your search.")
  %>

  <span class="col-md-5">
    <%= select_tag :"research_output[subject_filter]",
                   options_for_select(ResearchOutputPresenter.selectable_subjects),
                   include_blank: _("- Select a subject area -"),
                   class: "form-select",
                   title: by_subject_tooltip,
                   data: { toggle: "tooltip", placement: "bottom" } %>
  </span>

  <span class="col-md-5">
    <%= select_tag :"research_output[type_filter]",
                   options_for_select(ResearchOutputPresenter.selectable_repository_types),
                   include_blank: _("- Select a repository type -"),
                   class: "form-select",
                   title: by_type_tooltip,
                   data: { toggle: "tooltip", placement: "bottom" } %>
  </span>
<% end %>
```
