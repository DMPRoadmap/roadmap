# frozen_string_literal: true

module Dmptool

  module Controller

    module Orgs

      # GET /org_logos/:id (format: :json)
      def show
        skip_authorization
        org = Org.find(params[:id])
        render json: {
          "org" => {
            "id" => params[:id],
            "html" => render_to_string(partial: "shared/org_branding",
                                       locals: { org: org },
                                       formats: [:html])
          }
        }.to_json
      end

    end

  end

end
