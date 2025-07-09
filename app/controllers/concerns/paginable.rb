# frozen_string_literal: true

# Provides support for pagination/searching/sorting of table data
# rubocop:disable Metrics/ModuleLength
module Paginable
  extend ActiveSupport::Concern
  require 'sort_direction'

  ##
  # Regex to validate sort_field param is safe
  SORT_COLUMN_FORMAT = /[\w_]+\.[\w_]+$/

  PAGINATION_QUERY_PARAMS = %i[page sort_field sort_direction
                               search controller action].freeze

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
  #
  # Disabling this rubocop check here because it would require too much refactoring
  # one approach to just include everything in the double splat `**options` param

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/ParameterLists
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def paginable_renderise(partial: nil, template: nil, controller: nil, action: nil,
                          path_params: {}, query_params: {}, scope: nil,
                          locals: {}, **options)
    unless scope.is_a?(ActiveRecord::Relation)
      raise ArgumentError, _('scope should be an ActiveRecord::Relation object')
    end
    raise ArgumentError, _('path_params should be a Hash object') unless path_params.is_a?(Hash)
    raise ArgumentError, _('query_params should be a Hash object') unless query_params.is_a?(Hash)
    raise ArgumentError, _('locals should be a Hash object') unless locals.is_a?(Hash)

    # Default options
    @paginable_options = {}.merge(options)
    @paginable_options[:view_all] = options.fetch(:view_all, true)
    @paginable_options[:remote] = options.fetch(:remote, true)
    # Assignment for paginable_params based on arguments passed to the method
    @args = paginable_params.to_h
    @args[:controller] = controller if controller
    @args[:action] = action if action

    # if duplicate keys, those from @paginable_params take precedence
    @args = query_params.symbolize_keys.merge(@args)
    # Additional path_params passed to this function got special treatment
    # (e.g. it is taking into account when building base_url)
    @paginable_path_params = path_params.symbolize_keys
    if @args[:page] == 'ALL' &&
       @args[:search].blank? &&
       @paginable_options[:view_all] == false
      render(
        status: :forbidden,
        html: _('Restricted access to View All the records')
      )
    else
      @refined_scope = refine_query(scope)
      locals = locals.merge(
        scope: @refined_scope,
        paginable_params: @args,
        search_term: @args[:search],
        remote: @paginable_options[:remote]
      )
      # If this was an ajax call then render as JSON
      if options[:format] == :json
        render json: { html: render_to_string(layout: '/layouts/paginable',
                                              partial: partial, locals: locals) }
      elsif partial.present?
        render(layout: '/layouts/paginable', partial: partial, locals: locals)
      else
        render(template: template, locals: locals)
      end
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/ParameterLists
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # Returns the base url of the paginable route for a given page passed
  def paginable_base_url(page = 1)
    @args = @args.with_indifferent_access
    url_params = @paginable_path_params.merge(
      controller: @args[:controller],
      action: @args[:action],
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
      class: 'paginable-action',
      data: { remote: @paginable_options[:remote] },
      aria: { label: sort_field }
    )
  end

  # Determines whether or not the latest request included the search functionality
  def searchable?
    @args[:search].present?
  end

  # Determines whether or not the scoped query is paginated or not
  def paginable?
    @refined_scope.respond_to?(:total_pages)
  end

  # Refine a scope passed to this concern if any of the params (search,
  # sort_field or page) are present
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def refine_query(scope)
    @args = @args.with_indifferent_access
    scope = scope.search(@args[:search]).distinct if @args[:search].present?
    # Can raise NoMethodError if the scope does not define a search method
    if @args[:sort_field].present?
      frmt = @args[:sort_field][SORT_COLUMN_FORMAT]
      raise ArgumentError, 'sort_field param looks unsafe' unless frmt

      # Can raise ActiveRecord::StatementInvalid (e.g. column does not
      # exist, ambiguity on column, etc)
      # how we contruct scope depends on whether sort field is in the
      # main table or in a related table
      scope_table = scope.klass.name.underscore
      parts = @args[:sort_field].partition('.')
      table_part = parts.first
      column_part = parts.last
      if scope_table == table_part.singularize
        order_field = ActiveRecord::Base.sanitize_sql(column_part)
        scope = scope.order(order_field.to_sym => sort_direction.to_s)
      else
        order_field = ActiveRecord::Base.sanitize_sql(@args[:sort_field])
        sd = ActiveRecord::Base.sanitize_sql(sort_direction)
        scope = scope.includes(table_part.singularize.to_sym)
                     .order("#{order_field} #{sd}")
      end
    end
    if @args[:page] != 'ALL'
      # Can raise error if page is not a number
      scope = scope.page(@args[:page])
                   .per(@args.fetch(:per_page, Rails.configuration.x.results_per_page))
    end
    scope
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def sort_direction
    @sort_direction ||= SortDirection.new(@args[:sort_direction])
  end

  # Returns the sort link name for a given sort_field. The link name includes
  # html prevented of being escaped
  def sort_link_name(sort_field)
    @args = @args.with_indifferent_access
    class_name = 'fas fa-sort'
    dir = 'up'
    dir = 'down' if sort_direction.to_s == 'DESC'
    class_name = "fas fa-sort-#{dir}" if @args[:sort_field] == sort_field
    <<~HTML.html_safe
      <i class="#{class_name}"
         aria-hidden="true"
         style="float: right; font-size: 1.2em;">

        <span class="screen-reader-text">
          #{format(_('Sort by %{sort_field}'), sort_field: sort_field.split('.').first)}
        </span>
      </i>
    HTML
  end

  # Returns the sort url for a given sort_field.
  # rubocop:disable Metrics/AbcSize
  def sort_link_url(sort_field)
    @args = @args.with_indifferent_access
    query_params = {}
    query_params[:page] = @args[:page] == 'ALL' ? 'ALL' : 1
    query_params[:sort_field] = sort_field
    query_params[:sort_direction] = if @args[:sort_field] == sort_field
                                      sort_direction.opposite
                                    else
                                      sort_direction
                                    end
    base_url = paginable_base_url(query_params[:page])
    sort_url = URI(base_url)
    sort_url.query = stringify_query_params(**query_params)
    sort_url.to_s
    "#{sort_url}&#{stringify_nonpagination_query_params}"
  end
  # rubocop:enable Metrics/AbcSize

  # Retrieve any query params that are not a part of the paginable concern
  def stringify_nonpagination_query_params
    @args.except(*PAGINATION_QUERY_PARAMS).to_param
  end

  def stringify_query_params(page: 1, search: @args[:search],
                             sort_field: @args[:sort_field],
                             sort_direction: nil)
    query_string = { page: page }
    query_string['search'] = search if search.present?
    if sort_field.present?
      query_string['sort_field'] = sort_field
      query_string['sort_direction'] = SortDirection.new(sort_direction)
    end
    query_string.to_param
  end

  def paginable_params
    params.permit(PAGINATION_QUERY_PARAMS)
  end
end
# rubocop:enable Metrics/ModuleLength
