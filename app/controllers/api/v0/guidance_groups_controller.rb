# frozen_string_literal: true

class Api::V0::GuidanceGroupsController < Api::V0::BaseController

  before_action :authenticate

  def index
    unless Api::V0::GuidanceGroupPolicy.new(@user, :guidance_group).index?
      raise Pundit::NotAuthorizedError
    end

    @all_viewable_groups = GuidanceGroup.all_viewable(@user)
    respond_with @all_viewable_groups
  end

  def pundit_user
    @user
  end

  private

  def query_params
    params.permit(:id)
  end

end
