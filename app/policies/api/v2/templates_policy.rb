# frozen_string_literal: true

module Api
  module V2
    # Endpoints for accessing Templates
    class TemplatesPolicy < ApplicationPolicy
      attr_reader :client

      def initialize(client, plan)
        @client = client
        super(client, plan)
      end

      # Scope to limit which templates the ApiClient has access to based on their perms
      class Scope
        attr_reader :client

        def initialize(client, scope)
          @client = client
          super(client, scope)
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
          return templates unless @client.respond_to?(:user) && @client.user&.org&.present?

          org_templates(templates: templates).flatten.compact.uniq
        end

        private

        # Fetch all of the User's Plans
        def public_templates
          Template.includes(org: :identifiers)
                  .joins(:org)
                  .published
                  .publicly_visible
                  .where(customization_of: nil)
                  .order(:title)
        end

        # Fetch all of the Org's templates along with their customizations
        # rubocop:disable Metrics/AbcSize
        def org_templates(templates: [])
          org_templates = Template.latest_version_per_org(@client.user.org).published
          custs = Template.latest_customized_version_per_org(@client.user.org).published
          return (templates + org_templates).sort { |a, b| a.title <=> b.title } unless custs.any?

          # Remove any templates that were customized by the org, we will use their customization
          templates.reject { |t| custs.map(&:customization_of).include?(t.family_id) }

          (org_templates + custs + templates).sort { |a, b| a.title <=> b.title }
        end
        # rubocop:enable Metrics/AbcSize
      end
    end
  end
end
