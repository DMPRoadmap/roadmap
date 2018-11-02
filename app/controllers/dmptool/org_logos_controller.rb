# frozen_string_literal: true

module Dmptool

  class OrgLogosController < ApplicationController

    after_action :verify_authorized, except: ['show']

    # GET /org_logos/:id (format: :json)
    def show
      org = Org.find(params[:id])
      render json: {
        "org" => {
          "id" => params[:id],
          "html" => render_to_string(partial: 'shared/org_branding',
                                     locals: { org: org },
                                     formats: [:html])
        }
      }.to_json
    end

  end

end

