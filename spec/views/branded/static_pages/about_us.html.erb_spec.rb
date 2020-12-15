# frozen_string_literal: true

require "rails_helper"

describe "static_pages/about_us.html.erb" do

  it "renders our version of the page" do
    controller.prepend_view_path "app/views/branded"
    render
    expect(rendered.include?("What is the DMPTool?")).to eql(true)
  end

end
