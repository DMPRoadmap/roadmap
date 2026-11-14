# frozen_string_literal: true

require 'rails_helper'
require 'zip'

RSpec.describe 'Plan DOCX export', type: :request do
  it 'returns a readable Word document with the plan title' do
    template = create(:template, phases: 1)
    phase = template.phases.first
    section = create(:section, phase: phase)
    create(:question, section: section)
    plan = create(:plan, :publicly_visible, template: template, title: 'Rubyzip compatibility plan')

    get plan_export_path(plan, format: :docx), params: { export: { question_headings: '1' } }

    expect(response).to have_http_status(:ok)
    Zip::File.open_buffer(response.body) do |archive|
      document = Nokogiri::XML(archive.read('word/document.xml'))
      expect(document.text).to include(plan.title, 'Plan Overview')
    end
  end
end
