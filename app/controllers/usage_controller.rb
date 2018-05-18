class UsageController < ApplicationController
  # GET /usage
  def index
    raise Pundit::NotAuthorizedError unless current_user.present? && (current_user.can_org_admin? || current_user.can_super_admin?)
    render('index', locals: { orgs: Org.all })
  end
end