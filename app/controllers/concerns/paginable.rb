module Paginable
  extend ActiveSupport::Concern
  
  included do
    # Renders paginable layout with the partial view passed
    # partial {String} - Represents a path to where the partial view is stored
    # controller {String} - Represents the name of the controller to handles the pagination
    # action {String} - Represents the method name within the controller
    # scope {ActiveRecord::Relation} - Represents scope variable
    # locals {Hash} - A hash objects with any additional local variables to be passed to the partial view
    def paginable_renderise(partial: nil, controller: params[:controller], action: params[:action], scope: nil, locals: {})
      raise ArgumentError, 'scope should be an instance of ActiveRecord::Relation class' unless scope.is_a?(ActiveRecord::Relation)
      raise ArgumentError, 'locals should be an instance of Hash' unless locals.is_a?(Hash)
      render(layout: '/layouts/paginable', partial: partial, locals: { 
        controller: controller,
        action: action,
        # The scope is paginable if it has been chained with page method from kaminari which contains methods such as total_pages
        paginable: scope.respond_to?(:total_pages), 
        scope: scope }.merge(locals))
    end
  end
end