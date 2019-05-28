module Dmpopidor
    module Controllers
      module Paginable
        module Users
  
          # /paginable/users/index/:page
          # Users without activity should not be displayed first
          def index
            authorize User
            if current_user.can_super_admin?
              scope = User.order("last_sign_in_at is NULL").includes(:roles)
            else
              scope = current_user.org.users.order("last_sign_in_at is NULL").includes(:roles)
            end
            paginable_renderise(
                partial: "index",
                scope: scope,
                view_all: !current_user.can_super_admin?
            )
          end
        end
      end
    end
  end