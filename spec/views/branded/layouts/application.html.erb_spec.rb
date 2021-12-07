# frozen_string_literal: true

require 'rails_helper'

describe 'layouts/application.html.erb' do
  before(:each) do
    @app_name = ApplicationService.application_name
    Rails.configuration.x.application.name = @app_name

    controller.prepend_view_path 'app/views/branded'
  end

  it 'renders correctly' do
    render
    expect(response).to render_template(partial: 'layouts/_analytics')
    expect(rendered.include?("<title>#{@app_name}")).to eql(true)
    expect(rendered.include?('rel="icon"')).to eql(true)
    expect(rendered.include?('rel="apple-touch-icon"')).to eql(true)
    expect(rendered.include?('rel="mask-icon"')).to eql(true)
    expect(rendered.include?('rel="manifest"')).to eql(true)
    expect(rendered.include?('js/application-')).to eql(true)
    expect(rendered.include?('href="/assets/application-')).to eql(true)

    expect(rendered.include?('<body class="t-generic">')).to eql(true)
    expect(rendered.include?('Skip to main content')).to eql(true)
    expect(rendered.include?('<header>')).to eql(true)
    expect(response).to render_template(partial: 'layouts/_header')
    expect(rendered.include?('<main id="maincontent" class="">')).to eql(true)
    expect(response).to render_template(partial: 'layouts/_notifications')
    expect(rendered.include?('spinner-border')).to eql(true)
    expect(rendered.include?('<footer>')).to eql(true)
    expect(response).to render_template(partial: 'layouts/_footer')
    expect(response).to render_template(partial: 'layouts/_json_constants')
  end

  it 'allows you to specify classes for the <main> tag' do
    classes = "#{Faker::Lorem.word} #{Faker::Lorem.word}"
    assign :main_class, classes
    render
    expect(rendered.include?("<main id=\"maincontent\" class=\"#{classes}\">")).to eql(true)
  end
end
