# frozen_string_literal: true

module Api
  module V3
    # Endpoints for Work in Progress (WIP) DMPs
    class WipsController < BaseApiController

      # GET /dmps
      def index
        authorize Wip.new
        @wips = WipPolicy::Scope.new(current_user, Wip.new).resolve
      end

      # POST /dmps
      def create
        wip = Wip.new(user: current_user, metadata: wip_params[:metadata])
        authorize wip

        if wip.save
          @wips = [wip]
          render json: render_to_string(template: '/wips/index'), status: :created
        else
          render_error(errors: wip.errors.full_messages, status: :bad_request)
        end
      end

      # PUT /dmps
      def update
        wip = Wip.find_by(id: params[:id])
        authorize wip

        if wip.update(metadata: wip_params[:metadata])
          @wips = [wip]
          render json: render_to_string(template: '/wips/index'), status: :success
        else
          render_error(errors: wip.errors.full_messages, status: :bad_request)
        end
      end

      # DELETE /dmps
      def destroy
        wip = Wip.find_by(id: params[:id])
        authorize wip

        if wip.destroy
          @wips = []
          render json: render_to_string(template: '/wips/index'), status: :success
        else
          render_error(errors: wip.errors.full_messages, status: :bad_request)
        end
      end

      private

      def wip_params
        params.require(:dmp).permit(plan_permitted_params).to_h
      end
    end
  end
end
