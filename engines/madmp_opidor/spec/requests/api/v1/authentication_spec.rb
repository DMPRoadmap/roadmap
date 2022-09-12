# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/authentication', type: :request do
  path '/api/v1/authenticate' do
    post('Creates a JSON Web Token used to query the API') do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :authentication, in: :body, schema: {
        type: :object,
        properties: {
          grant_type: { type: :string, default: 'authorization_code' },
          email: { type: :string },
          code: { type: :string }
        }
      }
      response(200, 'successful') do
        let(:authentication) do
          {
            grant_type: 'authorization_code',
            email: '123',
            code: '123'
          }
        end
        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end
end
