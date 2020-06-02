# frozen_string_literal: true

class FeedbackRequestPolicy < ApplicationPolicy

  attr_reader :user, :org

  def initialize(user, plan)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user

    @user = user
    @plan = plan
  end

  def request_feedback?
    @plan.administerable_by?(@user.id)
  end

end
