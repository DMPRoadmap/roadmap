# frozen_string_literal: true

class Paginable::DepartmentsController < ApplicationController

  after_action :verify_authorized
  respond_to :html

  include Paginable

  # /paginable/departments/index/:page
  def index
    authorize Department
    paginable_renderise(
      partial: "index",
      scope: departments,
      query_params: { sort_field: "departments.name", sort_direction: :asc },
      format: :json
    )
  end

  private

  def departments
    if current_user.can_super_admin?
      Department.by_org(Org.find(params[:id]))
    else
      Department.by_org(Org.find(current_user.org_id))
    end
  end

end
