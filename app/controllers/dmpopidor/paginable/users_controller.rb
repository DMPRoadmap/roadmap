# frozen_string_literal: true

module Dmpopidor
  module Paginable
    # Customized code for Paginable UsersController
    module UsersController
      # /paginable/users/index/:page
      # Users without activity should not be displayed first
      # rubocop:disable Metrics/AbcSize
      def index
        authorize ::User
        @clicked_through = params[:click_through].present?

        # variable containing the check box value
        @filter_admin = params[:filter_admin] == '1'

        scope = if current_user.can_super_admin?
                  ::User.includes(:department, :org, :perms, :roles, :identifiers)
                else
                  current_user.org.users.includes(:department, :org, :perms, :roles, :identifiers)
                end

        scope = scope.joins(:perms).distinct if @filter_admin

        paginable_renderise(
          partial: 'index',
          scope: scope.order('users.last_sign_in_at desc NULLS LAST'),
          query_params: { sort_field: 'users.last_sign_in_at', sort_direction: :desc },
          format: :json,
          view_all: !current_user.can_super_admin?
        )
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
