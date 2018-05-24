module Paginable
  extend ActiveSupport::Concern
  
  included do
    # Renders paginable layout with the partial view passed
    # partial {String} - Represents a path to where the partial view is stored
    # controller {String} - Represents the name of the controller to handles the pagination
    # action {String} - Represents the method name within the controller
    # path_params {Hash} - A hash of additional URL path parameters (e.g. path_paths = { id: 'foo' } for /paginable/templates/:id/history/:page)
    # query_params {Hash} - A hash of query parameters used to merge with params object from the controller for which this concern is included
    # scope {ActiveRecord::Relation} - Represents scope variable
    # locals {Hash} - A hash objects with any additional local variables to be passed to the partial view
    def paginable_renderise(partial: nil, controller: nil, action: nil, path_params: {}, query_params: {}, scope: nil, locals: {}, **options)
      raise ArgumentError, _('scope should be an ActiveRecord::Relation object') unless scope.is_a?(ActiveRecord::Relation)
      raise ArgumentError, _('path_params should be a Hash object') unless path_params.is_a?(Hash)
      raise ArgumentError, _('query_params should be a Hash object') unless query_params.is_a?(Hash) 
      raise ArgumentError, _('locals should be a Hash object') unless locals.is_a?(Hash)

      # Default options
      @paginable_options = {}.merge(options)
      @paginable_options[:view_all] = options.fetch(:view_all, true)
      # Assignment for paginable_params based on arguments passed to the method
      @paginable_params = params.symbolize_keys
      @paginable_params[:controller] = controller if controller
      @paginable_params[:action] = action if action
      @paginable_params = query_params.symbolize_keys.merge(@paginable_params) # if duplicate keys, those from @paginable_params take precedence
      # Additional path_params passed to this function got special treatment (e.g. it is taking into account when building base_url)
      @paginable_path_params = path_params.symbolize_keys
      if @paginable_params[:page] == 'ALL' && @paginable_params[:search].blank? && @paginable_options[:view_all] == false
        render(status: :forbidden, html: _('Restricted access to View All the records'))
      else
        @refined_scope = refine_query(scope)
        render(layout: "/layouts/paginable",
          partial: partial,
          locals: locals.merge({
            scope: @refined_scope,
            search_term: @paginable_params[:search] }))
      end
    end
    # Returns the base url of the paginable route for a given page passed
    def paginable_base_url(page = 1)
      return url_for(@paginable_path_params.merge({ controller: @paginable_params[:controller],
        action: @paginable_params[:action], page: page }))
    end
    # Returns the base url of the paginable router for a given page passed together with its query_params.
    # It is used to retain context, i.e. search, sort_field, sort_direction, etc
    def paginable_base_url_with_query_params(page: 1, **stringify_query_params_options)
      base_url = paginable_base_url(page)
      stringified_query_params = stringify_query_params(stringify_query_params_options)
      if stringified_query_params.present?
        return "#{base_url}?#{stringified_query_params}"
      end
      return base_url
    end
    # Generates an HTML link to sort given a sort field.
    # sort_field {String} - Represents the column name for a table
    def paginable_sort_link(sort_field)
      return link_to(sort_link_name(sort_field), sort_link_url(sort_field), 'data-remote': true, class: 'paginable-action')
    end
    # Determines whether or not the latest request included the search functionality
    def searchable?
      return @paginable_params[:search].present?
    end
    # Determines whether or not the scoped query is paginated or not
    def paginable?
      return @refined_scope.respond_to?(:total_pages)
    end
  end
  private
    # Returns the upcase string (e.g ASC or DESC) if sort_direction param is present in any of the forms 'asc', 'desc', 'ASC', 'DESC'
    # otherwise returns ASC
    def upcasing_sort_direction(direction = @paginable_params[:sort_direction])
      directions = ['asc', 'desc', 'ASC', 'DESC']
      return directions.include?(direction) ? direction.upcase : 'ASC'
    end
    # Returns DESC when ASC is passed and vice versa, otherwise nil
    def swap_sort_direction(direction = @paginable_params[:sort_direction])
      direction_upcased = upcasing_sort_direction(direction)
      return 'DESC' if direction_upcased == 'ASC'
      return 'ASC' if direction_upcased == 'DESC'
    end
    # Refine a scope passed to this concern if any of the params (search, sort_field or page) are present
    def refine_query(scope)
      scope = scope.search(@paginable_params[:search]) if @paginable_params[:search].present? # Can raise NoMethodError if the scope does not define a search method
      if @paginable_params[:sort_field].present?
        scope = scope.order("#{@paginable_params[:sort_field]} #{upcasing_sort_direction}") # Can raise ActiveRecord::StatementInvalid (e.g. column does not exist, ambiguity on column, etc)
      end
      if @paginable_params[:page] != 'ALL'
        scope = scope.page(@paginable_params[:page]) # Can raise error if page is not a number
      end
      return scope
    end
    # Returns the sort link name for a given sort_field. The link name includes html prevented of being escaped
    def sort_link_name(sort_field)
      className = 'fa-sort'
      if @paginable_params[:sort_field] == sort_field
        className = upcasing_sort_direction == 'ASC'? 'fa-sort-asc' : 'fa-sort-desc'
      end
      return raw("<i class=\"fa #{className}\" aria-hidden=\"true\" style=\"float: right; font-size: 1.2em;\"></i>")
    end
    # Returns the sort url for a given sort_field.
    def sort_link_url(sort_field)
      page = @paginable_params[:page] == 'ALL' ? 'ALL' : 1
      if @paginable_params[:sort_field] == sort_field
        sort_url = paginable_base_url_with_query_params(
            page: page,
            sort_field: sort_field,
            sort_direction: swap_sort_direction)
      else
        sort_url = paginable_base_url_with_query_params(
          page: page,
          sort_field: sort_field)
      end
      return "#{sort_url}#{stringify_nonpagination_query_params}"
    end
    # Retrieve any query params that are not a part of the paginable concern
    def stringify_nonpagination_query_params
      other_params = @paginable_params.select do |param|
        ![:page, :sort_field, :sort_direction, :search, :controller, :action].include?(param)
      end
      return other_params.empty? ? '' : "&#{other_params.collect{ |k, v| "#{k}=#{v}" }.join('&')}"
    end
    def stringify_query_params(
      search: @paginable_params[:search],
      sort_field: @paginable_params[:sort_field],
      sort_direction: nil)

      query_string = []
      query_string << "search=#{search}" if search.present?
      if sort_field.present?
        query_string << "sort_field=#{sort_field}"
        direction = sort_direction || upcasing_sort_direction
        query_string << "sort_direction=#{direction}"
      end
      return query_string.join('&')
    end
end