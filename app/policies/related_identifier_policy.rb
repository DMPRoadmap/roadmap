# frozen_string_literal: true

class RelatedIdentifierPolicy < ApplicationPolicy

  attr_reader :user, :plan

  def initialize(user, plan)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user

    @user = user
    @plan = plan
  end

  def new?
    @plan.administerable_by?(@user.id)
  end

end
