class ResearchProjectsController < ApplicationController

  def index
    render json: research_projects
  end

  def search
    @results = research_projects.select { |r| r.description.match(params[:description]) }
    render json: @results
  end

  def default_funder_type
    Rails.configuration.x.open_aire&.default_funder || "H2020"
  end

  private

  def research_projects
    @research_projects ||= begin
      Rails.cache.fetch(["research_projects", funder_type], expires_in: 1.day) do
        Thread.new { OpenAireRequest.new(funder_type).get!.results }.value
      end
    end
  end

  def funder_type
    params.fetch(:type, default_funder_type)
  end

end
