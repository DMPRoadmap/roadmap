module Filterable
  extend ActiveSupport::Concern

  module ClassMethods
    # Allows creating a chainable query given a hash of filter_params passed
    # filter_params argument must be a Hash with at least paginable_all key, otherwise ArgumentError is raised
    # It raises NoMethodError if the value of the key passed is different from ActiveRecord::Relation and it does
    # not define a method with the same name as the key passed
    # 
    # User.filter({ paginable_all: current_user.org.users.includes(:roles), paginable_page: 1, search: "@gmail.com" })
    # will retrieve every user within the same org as the current user with an email including @gmail.com and limitting results to 10
    #
    # User.filter({ paginable_all: 10, paginable_page: 1, search: "@gmail.com", paginable_sort_last_sign_in_at: "desc" })
    # will retrieve every user within the org_id 10 with an email including @gmail.com, order by email descendant and limitting results to 10
    def filter(filter_params)
      raise(ArgumentError, "hash expected for params") unless filter_params.is_a?(Hash)
      raise(ArgumentError, "paginable_all key is expected for params") unless filter_params.has_key?(:paginable_all)
      # First creates the query for all the records, it may raise NoMethodError
      result = filter_params[:paginable_all].is_a?(ActiveRecord::Relation) ? 
        filter_params[:paginable_all] : self.send(:paginable_all, filter_params[:paginable_all])
      # Filters by page if paginable_page present
      result = result.send(:page, filter_params[:paginable_page]) if filter_params[:paginable_page].present?
      # Removes key/value paginable_all and paginable_page
      filter_params.delete(:paginable_all)
      filter_params.delete(:paginable_page)
      # Applies any other filter method scope if value is present
      filter_params.each_pair do |key, value|
        if value.present?
          if value.is_a?(ActiveRecord::Relation)
            result = value
          else
            result = result.send(key, value)  # Raises NoMethodError if the method does not exist at result object
          end
        end
      end
      result
    end
  end
end