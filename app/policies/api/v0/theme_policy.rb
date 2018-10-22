module Api
    module V0
      class ThemePolicy < ApplicationPolicy
        attr_reader :user, :theme
  
        def initialize(user, theme)
          raise Pundit::NotAuthorizedError, _("must be logged in") unless user
          unless user.org.token_permission_types.include? TokenPermissionType::THEMES
            raise Pundit::NotAuthorizedError, _("must have access to theme api")
          end
          @user = user
          @theme = theme
        end
  
        ##
        # always allowed as index chooses which themes to display
        def extract?
          true
        end
  
      end
    end
  end