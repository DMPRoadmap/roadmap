# frozen_string_literal: true

require "swagger_helper"

describe "Templates API" do

# TODO: Will uncomment this once Swagger setup has been finalized
=begin
  path "/api/v1/templates" do

    get 'Returns the templates' do
      tags "Templates"
      consumes "application/x-www-form-urlencoded"
      security [http: []]

      parameter name: :authorization, in: :header, type: :string

      response "200", "success" do
        run_test!
      end

      response "401", "authorization failed - please provide your credentials" do
        run_test!
      end

    end

  end
=end

end
