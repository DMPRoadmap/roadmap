# frozen_string_literal: true

# Security rules for the public pages
# Note the method names here correspond with controller actions
class PublicPagePolicy < ApplicationPolicy
  # rubocop:disable Lint/MissingSuper
  def initialize(user, record = nil)
    @user = user
    @record = record
  end
  # rubocop:enable Lint/MissingSuper

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
    @record.present? && @record.publicly_visible?
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
