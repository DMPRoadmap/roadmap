# frozen_string_literal: true

class ResearchProjectsController < ApplicationController

  def index
    render json: research_projects
  end

  def search
    @results = research_projects.select { |r| r.description.match(params[:description]) }
    render json: @results
  end

  private

  def research_projects
    return @research_projects unless @research_projects.nil? ||
                                     @research_projects.empty?

<<<<<<< HEAD
    # Check the cache contents as well since the instance variable is only
    # relevant per request
    cached = Rails.cache.fetch(["research_projects", funder_type])
    return @research_projects = cached unless cached.nil? || cached.empty?

    @research_projects = fetch_projects
=======
    # If the cache is empty for some reason, delete the key
    Rails.cache.delete(["research_projects", funder_type])

    @research_projects = begin
      Rails.cache.fetch(["research_projects", funder_type], expires_in: 1.day) do
        Thread.new { ExternalApis::OpenAireService.search(funder: funder_type) }.value
      end
    end
>>>>>>> bb5a32ed... updated identifier and identifiable and org_Selector
  end

  def funder_type
    params.fetch(:type, ExternalApis::OpenAireService.default_funder)
<<<<<<< HEAD
  end

  def fetch_projects
    Rails.cache.fetch(["research_projects", funder_type], expires_in: 1.day) do
      Thread.new { ExternalApis::OpenAireService.search(funder: funder_type) }.value
    end
=======
>>>>>>> bb5a32ed... updated identifier and identifiable and org_Selector
  end

end
