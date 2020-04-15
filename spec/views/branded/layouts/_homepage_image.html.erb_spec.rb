# frozen_string_literal: true

require "rails_helper"

describe "layouts/_homepage_image.html.erb" do

  it "renders correctly" do
    controller.prepend_view_path "app/views/branded"
    render
    expect(rendered.include?("Welcome to the DMPTool")).to eql(true)
    expect(rendered.include?("Get started")).to eql(true)
  end

end
