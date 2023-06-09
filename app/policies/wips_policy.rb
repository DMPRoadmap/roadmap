# frozen_string_literal: true

# Base policy for Plan endpoints
class WipsPolicy < ApplicationPolicy
  attr_reader :user, :wip

  def initialize(user, wip)
    @user = user
    @wip = wip
    super(user, wip)
  end

  class Scope
    attr_reader :user, :wip

    def initialize(user, wip)
      raise Pundit::NotAuthorizedError, 'must be logged in' unless user

      @user = user
      @wip = wip
    end

    def resolve

puts "ID: #{@user.id}"

      Wip.where(user_id: @user.id)
    end
  end
end
