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
    def paginable_renderise(partial: nil, controller: nil, action: nil, path_params: {}, query_params: {}, scope: nil, locals: {})
      raise ArgumentError, 'scope should be an ActiveRecord::Relation object' unless scope.is_a?(ActiveRecord::Relation)
      raise ArgumentError, 'path_params should be a Hash object' unless path_params.is_a?(Hash)
      raise ArgumentError, 'query_params should be a Hash object' unless query_params.is_a?(Hash) 
      raise ArgumentError, 'locals should be a Hash object' unless locals.is_a?(Hash)

      @paginable_params = params.symbolize_keys
      @paginable_params[:controller] = controller if controller
      @paginable_params[:action] = action if action
      @paginable_params = query_params.symbolize_keys.merge(@paginable_params) # if duplicate keys, those from @paginable_params take precedence

      @paginable_path_params = path_params.symbolize_keys

      refined_scope = refine_query(scope)
      render(layout: "/layouts/paginable", partial: partial, locals: { 
        controller: @paginable_params[:controller],
        action: @paginable_params[:action],
        paginable: refined_scope.respond_to?(:total_pages), 
        scope: refined_scope,
        search_term: @paginable_params[:search] }.merge(locals))
    end
    # Returns the base url of the paginable route for a given page passed
    def paginable_base_url(page = 1)
      return url_for(@paginable_path_params.merge({ controller: @paginable_params[:controller],
        action: @paginable_params[:action], page: page }))
    end
    # Returns the base url of the paginable router for a given page passed together with its query_params.
    # It is used to retain context, i.e. search, sort_field, sort_direction, etc
    def paginable_base_url_with_query_params(page: 1, query_options: {})
      base_url = paginable_base_url(page)
      stringified_query_params = stringify_query_params(query_options)
      if stringified_query_params.present?
        return "#{base_url}?#{stringified_query_params}"
      end
      return base_url
    end
    # Generates an HTML link to sort given a sort field.
    # sort_field {String} - Represents the column name for a table
    def paginable_sort_link(sort_field)
      return link_to(sort_link_name(sort_field), sort_link_url(sort_field), 'data-remote': true)
    end
    # Determines whether or not the latest request included the search functionality
    def searchable?
      return @paginable_params[:search].present?
    end
  end
  private
    # Returns the upcase string (e.g ASC or DESC) if sort_direction param is present in any of the forms 'asc', 'desc', 'ASC', 'DESC'
    # otherwise returns nil
    def upcasing_sort_direction
      if @paginable_params[:sort_direction].present?
        directions = ['asc', 'desc', 'ASC', 'DESC']
        return directions.include?(@paginable_params[:sort_direction]) ? @paginable_params[:sort_direction].upcase : 'ASC'
      end
      return nil
    end
    # Returns DESC when ASC is passed and vice versa, otherwise nil
    def swap_sort_direction(direction)
      return 'DESC' if direction == 'ASC'
      return 'ASC' if direction == 'DESC'
    end
    # Refine a scope passed to this concern if any of the params (search, sort_field or page) are present
    # TODO refactor using yield_self???
    def refine_query(scope)
      scope = scope.search(@paginable_params[:search]) if @paginable_params[:search].present? # Can raise NoMethodError if the scope does not define a search method
      if @paginable_params[:sort_field].present?
        direction = upcasing_sort_direction
        scope = direction.present? ? scope.order("#{@paginable_params[:sort_field]} #{direction}") : scope.order("#{@paginable_params[:sort_field]}") # Can raise ActiveRecord::StatementInvalid (e.g. column does not exist, ambiguity on column, etc)
      end
      if @paginable_params[:page] != 'ALL'
        scope = scope.page(@paginable_params[:page]) # Can raise error if page is not a number
      end
      return scope
    end
    # Returns the sort link name for a given sort_field. The link name includes html prevented of being escaped
    def sort_link_name(sort_field)
      className = 'fa-sort'
      direction = upcasing_sort_direction
      if direction.present? && @paginable_params[:sort_field] == sort_field
        className = direction == 'ASC'? 'fa-sort-asc' : 'fa-sort-desc'
      end
      return raw("<i class=\"fa #{className}\" aria-hidden=\"true\" style=\"float: right; font-size: 1.2em;\"></i>")
    end
    # Returns the sort url for a given sort_field.
    def sort_link_url(sort_field)
      direction = upcasing_sort_direction
      page = @paginable_params[:page] == 'ALL' ? 'ALL' : 1
      if direction.present? && @paginable_params[:sort_field] == sort_field
        return paginable_base_url_with_query_params(page: page, query_options: {
          sort_field: sort_field,
          sort_direction: swap_sort_direction(direction)})
      else
        return paginable_base_url_with_query_params(page: page, query_options: {
          sort_field: sort_field })
      end
    end
    def stringify_query_params(options = { remove_search: false })
      options[:search] = @paginable_params[:search] unless options[:remove_search].present?
      options[:sort_field] = options[:sort_field] || @paginable_params[:sort_field]
      options[:sort_direction] = options[:sort_direction] || upcasing_sort_direction
      query_string = []
      query_string << "search=#{options[:search]}" if options[:search].present?
      query_string << "sort_field=#{options[:sort_field]}" if options[:sort_field].present?
      query_string << "sort_direction=#{options[:sort_direction]}" if options[:sort_direction].present?
      return query_string.join('&')
    end
end