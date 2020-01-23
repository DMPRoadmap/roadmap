# frozen_string_literal: true

require "swagger_helper"

describe "Authentication API" do

# TODO: Will uncomment this once Swagger setup has been finalized
=begin
  path "/api/v1/authenticate" do

    post 'Issues an authorization token' do
      tags "Authentication"

      consumes %w[application/json]
      produces %w[application/json]

      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          grant_type: { type: :string, example: "client_credentials" },
          client_id: { type: :string, example: "<My client id>" },
          client_secret: { type: :string, example: "<My client secret>" }
        },
        required: %w[grant_type client_id client_secret]
      }

      response "200", "authentication successful" do
        let(:client) { create(:api_client) }
        let(:credentials) do
          { grant_type: "client_credentials", client_id: client.client_id,
            client_secret: client.client_secret }
        end
        run_test!
      end

      response "400", "missing or invalid JSON" do
        run_test!
      end

      response "401", "unauthorized" do
        run_test!
      end
    end

  end
=end

end
