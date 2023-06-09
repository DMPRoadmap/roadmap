# frozen_string_literal: true

# Controller for the React based Dashboards
class DashboardsController < ApplicationController
  def show
    render :show, layout: 'react_application'
  end
end
