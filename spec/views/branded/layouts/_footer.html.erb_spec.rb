# frozen_string_literal: true

require 'rails_helper'

describe 'layouts/_footer.html.erb' do
  before do
    controller.prepend_view_path 'app/views/branded'
  end

  it 'renders properly' do
    Rails.configuration.x.dmptool.version = Faker::Number.number
    render
    expect(rendered.include?('<footer class="c-footer">')).to be(true)
    expect(rendered.include?('class="c-logo-cdl"')).to be(true)
    expect(rendered.include?('class="c-footernav"')).to be(true)
    expect(rendered.include?('About')).to be(true)
    expect(rendered.include?('Contact Us')).to be(true)
    expect(rendered.include?('Terms of Use')).to be(true)
    expect(rendered.include?('Privacy Statement')).to be(true)
    expect(rendered.include?('Github')).to be(true)
    expect(rendered.include?('Accessibility')).to be(true)
    expect(rendered.include?('Site Map')).to be(true)
    expect(rendered.include?('class="c-copyright"')).to be(true)
    expect(rendered.include?("Version: #{Rails.configuration.x.dmptool.version}")).to be(true)
  end
end
