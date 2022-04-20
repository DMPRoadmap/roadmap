# frozen_string_literal: true

module Api

  module V0
<<<<<<< HEAD

    class TemplatePolicy < ApplicationPolicy

      attr_reader :user, :template

=======
    # Security rules for API V0 Template endpoints
    class TemplatePolicy < ApplicationPolicy
>>>>>>> upstream/master
      def initialize(user, template)
        unless user.org.token_permission_types.include? TokenPermissionType::TEMPLATES
          raise Pundit::NotAuthorizedError, _('must have access to templates api')
        end

<<<<<<< HEAD
        @user = user
        @template = template
=======
        super(user, template)
>>>>>>> upstream/master
      end

      ##
      # always allowed as index chooses which guidances to display
      def index?
        true
      end
    end

  end
<<<<<<< HEAD

=======
>>>>>>> upstream/master
end
