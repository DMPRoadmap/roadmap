# frozen_string_literal: true

class WipsController < ApplicationController
  # The following actions handle instances where a user has bookmarked, copy/pasted, refreshed the page, etc.
  # for one of the React UI paths. We need to have Rails render the default ERB template and the react-router
  # will handle it from there

  # GET /dmps/new
  def new
    authorize Wip.new
    render template: '/dashboards/show', layout: 'react_application'
  end

  # GET /dmps/funders
  def funders
    authorize Wip.new
    render template: '/dashboards/show', layout: 'react_application'
  end

  # GET /dmps/overview
  def overview
    authorize Wip.new
    render template: '/dashboards/show', layout: 'react_application'
  end
end
