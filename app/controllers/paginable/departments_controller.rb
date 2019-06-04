# frozen_string_literal: true

class  Paginable::DepartmentsController < ApplicationController

  after_action :verify_authorized
  respond_to :html

  include Paginable

  # /paginable/departments/index/:page
  def index
    authorize Department
    paginable_renderise(
      partial: "index",
      scope: Department.by_org(current_user.org),
      query_params: { sort_field: "departments.name", sort_direction: :asc }
    )
  end

end
