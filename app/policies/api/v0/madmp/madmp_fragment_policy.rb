# frozen_string_literal: true

class Api::V0::Madmp::MadmpFragmentPolicy < ApplicationPolicy

  attr_reader :user
  attr_reader :madmp_fragment

  def initialize(user, madmp_fragment)
    raise Pundit::NotAuthorizedError, _("must be logged in") unless user

    @user     = user
    @fragment = madmp_fragment
  end

  def show?
    plan = @fragment.plan
    plan.readable_by?(@user.id)
  end

  def update?
    plan = @fragment.plan
    plan.editable_by?(@user.id)
  end

end
