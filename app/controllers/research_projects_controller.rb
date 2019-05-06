class ResearchProjectsController < ApplicationController


  DEFAULT_FUNDER_TYPE = "H2020"

  def index
    render json: research_projects
  end

  def search
    @results = research_projects.select { |r| r.description.match(params[:description]) }
    logger.debug("Returning #{@results.count} results")
    render json: @results
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
    params.fetch(:type, DEFAULT_FUNDER_TYPE)
  end

end
