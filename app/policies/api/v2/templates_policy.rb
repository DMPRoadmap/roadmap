# frozen_string_literal: true

module Api

  module V2

    class TemplatesPolicy < ApplicationPolicy

      attr_reader :client, :plan

      def initialize(client, plan)
        @client = client
        @plan = plan
      end

      class Scope

        attr_reader :client, :scope

        def initialize(client, scope)
          @client = client
          @scope = scope
        end

        ## Return the templates to a given client depending on the context
        #
        #   - ALL can view: public
        #   - when @client is a User and an Org Admin can view:
        #       - (when an admin) all Templates for their organisation
        #
        def resolve
          # Only return publicly visible Templates if the caller is an ApiClient
          templates = public_templates
          return templates if @client.is_a?(ApiClient)

          org_templates(templates: templates).flatten.compact.uniq
        end

        private

        def validate_scopes(required_scopes:)
          return true if @client.trusted?

          required_scopes.blank? || required_scopes.any? { |scope| required_scopes.include?(scope.to_s) }
        end

        # Fetch all of the User's Plans
        def public_templates
          return [] unless validate_scopes(required_scopes: %w[read_public_templates])

          Template.includes(org: :identifiers)
                  .joins(:org)
                  .published
                  .publicly_visible
                  .where(customization_of: nil)
                  .order(:title)
        end

        # Fetch all of the Org's templates along with their customizations
        def org_templates(templates: [])
          return [] unless validate_scopes(required_scopes: %w[read_your_templates])

          where_clause = <<-SQL
            (visibility = 0 AND org_id = ?) OR
            (visibility = 1 AND customization_of IS NULL)
          SQL
          org_owned = Template.includes(org: :identifiers)
                              .joins(:org)
                              .published
                              .where(where_clause, @client.org&.id)
                              .order(:title)
          # Favor the Org customized version of any public templates
          org_owned += templates.reject { |tmplt| org_owned.map(&:customization_of).include?(tmplt.family_id) }
          org_owned
        end

      end

    end

  end

end
