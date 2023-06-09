# frozen_string_literal: true

class WipsController < ApplicationController
  respond_to :json

  # GET /wips
  def index
    @wips = WipsPolicy::Scope.new(current_user, Wip.new).resolve
  end
end
