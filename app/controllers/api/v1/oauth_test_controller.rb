# frozen_string_literal: true

module Api

  module V1

    # Base API Controller
    class BaseApiController < ApplicationController

      respond_to :json

      before_action :doorkeeper_authorize!

    end

    # POST api/v1/test
    def test

    end

  end

end
