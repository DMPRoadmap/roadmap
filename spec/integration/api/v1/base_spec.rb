# frozen_string_literal: true

require "swagger_helper"

describe "Heartbeat API" do

# TODO: Will uncomment this once Swagger setup has been finalized
=begin
  path "/api/v1/heartbeat" do

    get "Endpoint to determine whether or not the API is online" do
      tags "Heartbeat"
      produces "application/json"

      response "200", "API is online" do
        run_test!
      end

      response "503", "API is offline" do
        run_test!
      end

    end

  end
=end

end
