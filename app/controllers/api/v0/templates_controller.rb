module Api
  module V0
    class TemplatesController < Api::V0::BaseController
      before_action :authenticate


      ##
      # GET
      # @return a list of templates ordered by organisation
      def index
        # check if the user has permissions to use the templates API
        if has_auth(constant("api_endpoint_types.templates"))
          @org_templates = {}
          published_templates = Template.includes(:org).where(customization_of: nil, published: true).order(:org_id, :version)
          published_templates.all.each do |temp|
            if @org_templates[temp.org].present?
              if @org_templates[temp.org][temp.dmptemplate_id].nil?
                @org_templates[temp.org][temp.dmptemplate_id] = temp
              end
            else
              @org_templates[temp.org] = {}
              @org_templates[temp.org][temp.dmptemplate_id] = temp
            end
          end
          respond_with @org_templates
        else
          #render unauthorised
          render json: I18n.t("api.no_auth_for_endpoint"), status: 401
        end

      end
    end
  end
end