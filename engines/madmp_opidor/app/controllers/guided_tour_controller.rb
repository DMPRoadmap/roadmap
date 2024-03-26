# frozen_string_literal: true

# Controller for the GuidedTour Service, that handles guided tour state
class GuidedTourController < ApplicationController
  after_action :verify_authorized
  include Dmpopidor::ErrorHelper

  def get_tour
    tour_name = params[:tour]
    @guided_tour = current_user.guided_tours.find_or_create_by(tour: tour_name)

    authorize @guided_tour

    render json: { status: 200, tour: { name: tour_name, ended: @guided_tour.nil? ? false : @guided_tour.ended } }
  end

  def end_tour
    tour_name = params[:tour]

    begin
      @guided_tour = current_user.guided_tours.find_by(tour: tour_name)

      authorize @guided_tour

      return not_found("Guided tour '#{tour_name}' not found") unless @guided_tour

      @guided_tour.update(ended: true)
      render json: { status: 200, tour: { name: tour_name, ended: true } }
    rescue => e
      Rails.logger.error("An error occurred during ending the guided tour: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      internal_server_error('An error occurred during ending the guided tour')
    end
  end
end