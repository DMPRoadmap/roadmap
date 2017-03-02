module Api
  module V0
    class TemplatesController < Api::V0::BaseController
      before_action :authenticate


      ##
      # GET
      # @return a list of templates ordered by organisation
      def index
        # check if the user has permissions to use the templates API
        raise Pundit::NotAuthorizedError unless Api::V0::TemplatePolicy.new(@user, :guidance_group).index?
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
    end
    end
  end
end