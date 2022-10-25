# frozen_string_literal: true

require 'rails_helper'

describe 'public_pages/template_index.html.erb' do
  include Helpers::DmptoolHelper

  it 'renders our version of the page' do
    create_list(:template, 3)
    controller.prepend_view_path 'app/views/branded'
    assign :templates, Template.all
    assign :templates_query_params, { sort_field: 'templates.title', sort_direction: :asc }
    render
    expect(rendered.include?('Funder Requirements')).to be(true)
    expect(rendered.include?('Templates for data management plans are based')).to be(true)
    expect(response).to render_template(partial: 'paginable/templates/_publicly_visible')
  end
end
