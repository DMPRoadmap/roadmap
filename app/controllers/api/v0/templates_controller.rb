# frozen_string_literal: true

module Api
  module V0
    # Handles queries for templates for API V0
    class TemplatesController < Api::V0::BaseController
      before_action :authenticate

      # GET
      #
      # Renders a list of templates ordered by organisation
      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def index
        # check if the user has permissions to use the templates API
        raise Pundit::NotAuthorizedError unless Api::V0::TemplatePolicy.new(@user, :guidance_group).index?

        @org_templates = {}

        published_templates = Template.includes(:org)
                                      .unarchived
                                      .where(customization_of: nil, published: true)
                                      .order(:org_id, :version)

        customized_templates = Template.includes(:org)
                                       .unarchived
                                       .where(org_id: @user.org_id, published: true)
                                       .where.not(customization_of: nil)

        published_templates.order(:org_id, :version).each do |temp|
          if @org_templates[temp.org].present?
            @org_templates[temp.org][:own][temp.family_id] = temp if @org_templates[temp.org][:own][temp.family_id].nil?
          else
            @org_templates[temp.org] = {}
            @org_templates[temp.org][:own] = {}
            @org_templates[temp.org][:cust] = {}
            @org_templates[temp.org][:own][temp.family_id] = temp
          end
        end
        customized_templates.each do |temp|
          if @org_templates[temp.org].present?
            if @org_templates[temp.org][:cust][temp.family_id].nil?
              @org_templates[temp.org][:cust][temp.family_id] =
                temp
            end
          else
            @org_templates[temp.org] = {}
            @org_templates[temp.org][:own] = {}
            @org_templates[temp.org][:cust] = {}
            @org_templates[temp.org][:cust][temp.family_id] = temp
          end
        end
        respond_with @org_templates
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    end
  end
end
