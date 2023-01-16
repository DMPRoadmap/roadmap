# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/madmp/plans', type: :request do
  path '/api/v1/madmp/plans/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'Plan identifier'
    parameter name: 'export_format',
              in: :query, type: :string,
              description: 'Export format (standard/rda)',
              required: true,
              default: 'standard',
              enum: %w[standard rda]

    get('Export Plan in the Standard or RDA format') do
      tags 'Plans'
      produces 'application/json'
      security [Bearer: []]
      response(200, 'successful') do
        let(:id) { '123' }
        let(:export_format) { 'standard' }

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

  path '/api/v1/madmp/plans/research_outputs/{uuid}' do
    # You'll want to customize the parameter types...
    parameter name: 'uuid', in: :path, type: :string, description: 'ResearchOutput UUID'
    parameter name: 'export_format',
              in: :query, type: :string,
              description: 'Export format (standard/rda)',
              required: true,
              default: 'standard',
              enum: %w[standard rda]

    get('Export Plan, for a given research_output, in the Standard or RDA format') do
      tags 'Plans'
      produces 'application/json'
      security [Bearer: []]
      response(200, 'successful') do
        let(:uuid) { 'aa-22-aa-4444' }
        let(:export_format) { 'standard' }

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

  path '/api/v1/madmp/plans/import' do
    parameter name: 'import_format',
              in: :query, type: :string,
              description: 'Import format (standard/rda)',
              required: true,
              default: 'standard',
              enum: %w[standard rda]

    parameter name: :data, in: :body, schema: {
      type: :object
    }

    post('Import and create a new plan based on a Standard or RDA input format') do
      tags 'Plans'
      produces 'application/json'
      consumes 'application/json'
      security [Bearer: []]
      response(200, 'successful') do
        let(:import_format) { 'standard' }
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
