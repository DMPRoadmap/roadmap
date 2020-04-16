# frozen_string_literal: true

module Dmptool

  module Controllers

    module OrgsController

      # GET /org_logos/:id (format: :json)
      def logos
        skip_authorization
        org = Org.find(params[:id])
        @user = User.new(org: org)
        render json: {
          "org" => {
            "id" => params[:id],
            "html" => render_to_string(partial: "shared/org_branding",
                                       formats: [:html])
          }
        }.to_json
      end

      # GET /orgs/shibboleth_ds/:id
      # POST /orgs/shibboleth_ds/:id
      def shibboleth_ds_passthru
        skip_authorization
        org = Org.find_by(id: params[:id])

        if org.present?
          entity_id = org.identifier_for_scheme(scheme: "shibboleth")
          if entity_id.present?
            shib_login = Rails.application.config.shibboleth_login
            url = "#{request.base_url.gsub('http:', 'https:')}#{shib_login}"
            target = user_shibboleth_omniauth_callback_url.gsub("http:", "https:")

            # initiate shibboleth login sequence
            redirect_to "#{url}?target=#{target}&entityID=#{entity_id.value}"
          else
            @user = User.new(org: org)
            # render new signin showing org logo
            render "shared/org_branding"
          end
        else
          redirect_to shibboleth_ds_path,
                      notice: _("Please choose an organisation from the list.")
        end
      end

      private

      def sign_in_params
        params.require(:org).permit(:org_name, :org_sources, :org_crosswalk, :id)
      end

      def convert_params
        #expecting incoming params to look like:
        #   /orgs/shibboleth/173?org[id=173]
        #   /orgs/shibboleth/173?shib-ds[org_name=173]&shib-ds[org_id=173]]
        args = sign_in_params

        # POST params need to be converted over to a JSON object
        if args.is_a?(String)
          args = JSON.parse(args).with_indifferent_access
        else
          # For some reason when this comes through as a GET with query_params
          # it includes the closing bracket :/
          args[:id] = args[:id].gsub(/\]$/, "")
          args
        end
      end

    end

  end

end
