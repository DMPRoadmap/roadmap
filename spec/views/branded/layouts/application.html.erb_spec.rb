# frozen_string_literal: true

require 'rails_helper'

describe 'layouts/application.html.erb' do
  before do
    @app_name = ApplicationService.application_name
    Rails.configuration.x.application.name = @app_name

    controller.prepend_view_path 'app/views/branded'
  end

  it 'renders correctly' do
    render
    expect(response).to render_template(partial: 'layouts/_analytics')
    expect(rendered.include?("<title>#{@app_name}")).to be(true)
    expect(rendered.include?('rel="icon"')).to be(true)
    expect(rendered.include?('rel="apple-touch-icon"')).to be(true)
    expect(rendered.include?('rel="mask-icon"')).to be(true)
    expect(rendered.include?('rel="manifest"')).to be(true)
    expect(rendered.include?('href="/assets/application-')).to be(true)
    expect(rendered.include?('src="/dmptool-ui/main.js"')).to be(true)
    expect(rendered.include?('href="/dmptool-ui/main.css"')).to be(true)

    expect(rendered.include?('<body class="t-generic">')).to be(true)
    expect(rendered.include?('class="c-skipnav"')).to be(true)

    expect(rendered.include?('<header>')).to be(true)
    expect(response).to render_template(partial: 'layouts/_header')
    expect(response).to render_template(partial: 'layouts/_notifications')

    expect(rendered.include?('<main id="maincontent" class="">')).to be(true)
    expect(rendered.include?('spinner-border')).to be(true)

    expect(rendered.include?('<footer>')).to be(true)
    expect(response).to render_template(partial: 'layouts/_footer')

    expect(response).to render_template(partial: 'layouts/_json_constants')
  end

  it 'allows you to specify classes for the <main> tag' do
    classes = "#{Faker::Lorem.word} #{Faker::Lorem.word}"
    assign :main_class, classes
    render
    expect(rendered.include?("<main id=\"maincontent\" class=\"#{classes}\">")).to be(true)
  end
end
