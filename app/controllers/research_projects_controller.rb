# frozen_string_literal

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
    @research_projects ||= begin
      Rails.cache.fetch(["research_projects", funder_name], expires_in: 1.day) do
        Thread.new { OpenAireRequest.new(funder_name).get!.results }.value
      end
    end
  end

  def funder_name
    params[:funder_name] || "unsupported-funder"
  end

end
