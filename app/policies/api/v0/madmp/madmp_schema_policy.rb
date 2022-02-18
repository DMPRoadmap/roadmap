# frozen_string_literal: true

class Api::V0::Madmp::MadmpSchemaPolicy < ApplicationPolicy
  attr_reader :user, :madmp_schema

  def initialize(user, _madmp_fragment)
    raise Pundit::NotAuthorizedError, _('must be logged in') unless user

    @user = user
    @schema = madmp_schema
  end

  def show?
    true
  end
end
