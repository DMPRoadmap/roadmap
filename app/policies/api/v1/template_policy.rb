# frozen_string_literal: true

module Api

  module V1

    class TemplatePolicy < ApplicationPolicy

      def initialize(user, template)
        @user = user
        @template = template
      end

      class Scope < Scope
        ## return the visible plans (via the API) to a given client
        # ALL can view: public
        # ApiClient can view: anything from the API client
        # User (non-admin) can view: any personal or organisationally_visible
        # User (admin) can view: all from users of their organisation
        # rubocop:disable Metrics/AbcSize
        def resolve
          ids = scope.published
                     .publicly_visible
                     .where(customization_of: nil).pluck(:id)

          if user.is_a?(User)
            ids += user.org.templates.published.organisationally_visible.pluck(:id)
          end
          scope.includes(org: :identifiers).joins(:org)
               .where(id: ids.flatten.uniq).order(:title)
        end
        # rubocop:enable Metrics/AbcSize
      end

      def index?
        user.present?
      end

    end

  end

end
