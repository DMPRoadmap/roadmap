# frozen_string_literal: true

module Api

  module V1

    class PlansPolicy < ApplicationPolicy

      attr_reader :client, :plan

      class Scope

        attr_reader :client, :scope

        def initialize(client, scope)
          @client = client
          @scope = scope
        end

        ## return the visible plans (via the API) to a given client
        # ALL can view: public
        # ApiClient can view: anything from the API client
        #                     anything belonging to their Org (if applicable)
        # User (non-admin) can view: any personal or organisationally_visible
        # User (admin) can view: all from users of their organisation
        # rubocop:disable Metrics/AbcSize
        def resolve
          ids = Plan.publicly_visible.pluck(:id)
          case client
          when ApiClient
            ids += client.plans.pluck(&:id)
            ids += client.org.plans.pluck(&:id) if client.org.present?
          when User
            ids += client.org.plans.organisationally_visible.pluck(:id)
            ids += client.plans.pluck(:id)
            ids += client.org.plans.pluck(:id) if client.can_org_admin?
          end
          Plan.where(id: ids.uniq)
        end
        # rubocop:enable Metrics/AbcSize

      end

      def initialize(client, plan)
        @client = client
        @plan = plan
      end

    end

  end

end
