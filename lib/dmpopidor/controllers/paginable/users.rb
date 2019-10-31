module Dmpopidor
    module Controllers
      module Paginable
        module Users
  
          # /paginable/users/index/:page
          # Users without activity should not be displayed first
          def index
            authorize User
            if current_user.can_super_admin?
              scope = User.order("last_sign_in_at desc NULLS LAST").includes(:roles)
            else
              scope = current_user.org.users.order("last_sign_in_at desc NULLS LAST").includes(:roles)
            end
            
            paginable_renderise(
                partial: "index",
                scope: scope,
                query_params: { sort_field: 'users.last_sign_in_at', sort_direction: :desc },
                view_all: !current_user.can_super_admin?
            )
          end
        end
      end
    end
  end