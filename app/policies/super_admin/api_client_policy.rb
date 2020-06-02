# frozen_string_literal: true

module SuperAdmin

  class ApiClientPolicy < ApplicationPolicy

    attr_reader :user, :api_client

    def initialize(user, api_client)
      @user = user
      @api_client = api_client
    end

    def index?
      user.can_super_admin?
    end

    def new?
      user.can_super_admin?
    end

    def edit?
      user.can_super_admin?
    end

    def create?
      user.can_super_admin?
    end

    def update?
      user.can_super_admin?
    end

    def destroy?
      user.can_super_admin?
    end

    def refresh_credentials?
      user.can_super_admin?
    end

    def email_credentials?
      user.can_super_admin?
    end

  end

end
