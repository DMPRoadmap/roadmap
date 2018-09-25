# frozen_string_literal: true

module Paginable

  extend ActiveSupport::Concern

  ##
  # Regex to validate sort_field param is safe
  SORT_COLUMN_FORMAT = /[\w\_]+\.[\w\_]/

  PAGINATION_QUERY_PARAMS = [:page, :sort_field, :sort_direction,
                             :search, :controller, :action]

  private

  # Renders paginable layout with the partial view passed
  #
  # partial       - A String, represents a path to where the partial view is stored
  # controller    - A String, represents the name of the controller to handles the
  #                 pagination
  # action        - A String, represents the action name within the controller
  # path_params   - A Hash of additional URL path parameters
  #                 (e.g. path_paths = { id: 'foo' } for
  #                 /paginable/templates/:id/history/:page)
  # query_params  - A hash of query parameters used to merge with params object
  #                 from the controller for which this concern is included
  # scope         - An {ActiveRecord::Relation}, represents scope variable
  # locals        - A Hash objects with any additional local variables to be passed to
  #                 the partial view
  #
  # Returns String of valid HTML
  # Raises ArgumentError
  def paginable_renderise(partial: nil, controller: nil, action: nil,
                          path_params: {}, query_params: {}, scope: nil,
                          locals: {}, **options)
    unless scope.is_a?(ActiveRecord::Relation)
      raise ArgumentError, _("scope should be an ActiveRecord::Relation object")
    end
    unless path_params.is_a?(Hash)
      raise ArgumentError, _("path_params should be a Hash object")
    end
    unless query_params.is_a?(Hash)
      raise ArgumentError, _("query_params should be a Hash object")
    end
    unless locals.is_a?(Hash)
      raise ArgumentError, _("locals should be a Hash object")
    end

    # Default options
    @paginable_options = {}.merge(options)
    @paginable_options[:view_all] = options.fetch(:view_all, true)
    # Assignment for paginable_params based on arguments passed to the method
    @paginable_params = params.symbolize_keys
    @paginable_params[:controller] = controller if controller
    @paginable_params[:action] = action if action
    # if duplicate keys, those from @paginable_params take precedence
    @paginable_params = query_params.symbolize_keys.merge(@paginable_params)
    # Additional path_params passed to this function got special treatment
    # (e.g. it is taking into account when building base_url)
    @paginable_path_params = path_params.symbolize_keys
    if @paginable_params[:page] == "ALL" &&
       @paginable_params[:search].blank? &&
       @paginable_options[:view_all] == false
      render(
        status: :forbidden,
        html: _("Restricted access to View All the records")
      )
    else
      @refined_scope = refine_query(scope)
      render(layout: "/layouts/paginable",
        partial: partial,
        locals: locals.merge(
          scope: @refined_scope,
          search_term: @paginable_params[:search])
      )
    end
  end

  # Returns the base url of the paginable route for a given page passed
  def paginable_base_url(page = 1)
    url_params = @paginable_path_params.merge(
      controller: @paginable_params[:controller],
      action: @paginable_params[:action],
      page: page
    )
    url_for(url_params)
  end

  # Generates an HTML link to sort given a sort field.
  # sort_field {String} - Represents the column name for a table
  def paginable_sort_link(sort_field)
    link_to(
      sort_link_name(sort_field),
      sort_link_url(sort_field),
      class: "paginable-action",
      data: { remote: true },
      aria: { label: sort_field }
    )
  end

  # Determines whether or not the latest request included the search functionality
  def searchable?
    @paginable_params[:search].present?
  end

  # Determines whether or not the scoped query is paginated or not
  def paginable?
    @refined_scope.respond_to?(:total_pages)
  end

  # Refine a scope passed to this concern if any of the params (search,
  # sort_field or page) are present
  def refine_query(scope)
    if @paginable_params[:search].present?
      scope = scope.search(@paginable_params[:search])
    end
    # Can raise NoMethodError if the scope does not define a search method
    if @paginable_params[:sort_field].present?
      unless @paginable_params[:sort_field][SORT_COLUMN_FORMAT]
        raise ArgumentError, "sort_field param looks unsafe"
      end
      # Can raise ActiveRecord::StatementInvalid (e.g. column does not
      # exist, ambiguity on column, etc)
      scope = scope.order("#{@paginable_params[:sort_field]} #{sort_direction}")
    end
    if @paginable_params[:page] != "ALL"
      # Can raise error if page is not a number
      scope = scope.page(@paginable_params[:page])
    end
    scope
  end

  def sort_direction
    @sort_direction ||= SortDirection.new(@paginable_params[:sort_direction])
  end

  # Returns the sort link name for a given sort_field. The link name includes
  # html prevented of being escaped
  def sort_link_name(sort_field)
    class_name = "fa-sort"
    if @paginable_params[:sort_field] == sort_field
      class_name = "fa-sort-#{sort_direction.downcase}"
    end
    <<~HTML.html_safe
      <i class="fa #{class_name}"
         aria-hidden="true"
         style="float: right; font-size: 1.2em;">

        <span class="screen-reader-text">
          Sort by #{sort_field.split(".").first}
        </span>
      </i>
    HTML
  end

  # Returns the sort url for a given sort_field.
  def sort_link_url(sort_field)
    query_params = {}
    query_params[:page] = @paginable_params[:page] == "ALL" ? "ALL" : 1
    query_params[:sort_field] = sort_field
    if @paginable_params[:sort_field] == sort_field
      query_params[:sort_direction] = sort_direction.opposite
    else
      query_params[:sort_direction] = sort_direction
    end
    base_url = paginable_base_url(query_params[:page])
    sort_url = URI(base_url)
    sort_url.query = stringify_query_params(query_params)
    sort_url.to_s
    "#{sort_url}&#{stringify_nonpagination_query_params}"
  end

  # Retrieve any query params that are not a part of the paginable concern
  def stringify_nonpagination_query_params
    @paginable_params.except(*PAGINATION_QUERY_PARAMS).to_param
  end

  def stringify_query_params(page: 1, search: @paginable_params[:search],
    sort_field: @paginable_params[:sort_field],
    sort_direction: nil)

    query_string = {}
    query_string["search"] = search if search.present?
    if sort_field.present?
      query_string["sort_field"] = sort_field
      query_string["sort_direction"] = SortDirection.new(sort_direction)
    end
    query_string.to_param
  end

end
