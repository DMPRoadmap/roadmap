# frozen_string_literal: true

# Security rules for the public pages
# Note the method names here correspond with controller actions
class PublicPagePolicy < ApplicationPolicy
  # NOTE: @user is the signed_in_user and @record is an instance of Plan

  def plan_index?
    true
  end

  def template_index?
    true
  end

  def template_export?
    @record.present? && @record.published?
  end

  def plan_export?
    @record.publicly_visible?
  end

  def plan_organisationally_exportable?
    if @record.is_a?(Plan) && @user.is_a?(User)
      return @record.publicly_visible? ||
             (@record.organisationally_visible? && @record.owner.present? &&
              @record.owner.org_id == @user.org_id)
    end

    false
  end
end
