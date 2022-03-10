# frozen_string_literal: true

require 'rails_helper'

describe 'layouts/_footer.html.erb' do
  before(:each) do
    controller.prepend_view_path 'app/views/branded'
  end

  it 'renders properly' do
    Rails.configuration.x.dmptool.version = Faker::Number.number
    render
    expect(rendered.include?('<footer class="c-footer">')).to eql(true)
    expect(rendered.include?('class="c-logo-cdl"')).to eql(true)
    expect(rendered.include?('class="c-footernav"')).to eql(true)
    expect(rendered.include?('About')).to eql(true)
    expect(rendered.include?('Contact Us')).to eql(true)
    expect(rendered.include?('Terms of Use')).to eql(true)
    expect(rendered.include?('Privacy Statement')).to eql(true)
    expect(rendered.include?('Github')).to eql(true)
    expect(rendered.include?('Accessibility')).to eql(true)
    expect(rendered.include?('Site Map')).to eql(true)
    expect(rendered.include?('class="c-copyright"')).to eql(true)
    expect(rendered.include?("Version: #{Rails.configuration.x.dmptool.version}")).to eql(true)
  end
end
