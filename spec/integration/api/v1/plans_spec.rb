# frozen_string_literal: true

require "swagger_helper"

describe "Plans API" do

# TODO: Will uncomment this once Swagger setup has been finalized
=begin
  path "/api/v1/plans" do

    post 'Creates a plan' do
      tags "Plans"
      consumes "application/x-www-form-urlencoded"
      security [http: []]

      parameter name: :authorization, in: :header, type: :string

      parameter name: :json, in: :body, schema: {
        type: :object,
        properties: {
          total_items: { type: :integer, example: 1 },
          items: {
            type: :array,
            items: { "$ref": "#/definitions/dmp" }
          }
        }
      }

      response "201", "created" do
        run_test!
      end

      response "400", "bad request - if JSON is invalid or Plan already exists" do
        #schema '$ref': '#/definitions/bad_request_error'
        run_test!
      end

      response "401", "authorization failed - please provide your credentials" do
        run_test!
      end

    end

  end
=end

end
