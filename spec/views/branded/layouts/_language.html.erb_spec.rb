# frozen_string_literal: true

require "rails_helper"

describe "layouts/_language_menu.html.erb" do

  before(:each) do
    controller.prepend_view_path "app/views/branded"
  end

  it "renders nothing if only one Language is available" do
    render
    expect(rendered.include?("language-menu-button")).to eql(false)
  end

  it "renders correctly when multiple Languages are available" do
    3.times { create(:language) }
    render
    expect(rendered.include?("language-menu-button")).to eql(true)
    Language.all.each { |l| expect(rendered.include?(l.name)).to eql(true) }
  end

end
