# frozen_string_literal: true

module Dmpopidor

  module Controllers

    module Paginable

      module Users

        # /paginable/users/index/:page
        # Users without activity should not be displayed first
        def index
          authorize User
          @clicked_through = params[:click_through].present?

          # variable containing the check box value
          @filter_admin = params[:filter_admin] == "1"

          if current_user.can_super_admin?
            scope = User.includes(:roles)
          else
            scope = current_user.org.users.includes(:roles)
          end

          if @filter_admin
            scope = scope.joins(:perms).distinct
          end

          paginable_renderise(
              partial: "index",
              scope: scope.order("users.last_sign_in_at desc NULLS LAST"),
              query_params: { sort_field: 'users.last_sign_in_at', sort_direction: :desc },
              view_all: true
          )
        end

      end

    end

  end

end
