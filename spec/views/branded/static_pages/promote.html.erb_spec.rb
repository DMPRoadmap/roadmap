# frozen_string_literal: true

require "rails_helper"

describe "static_pages/promote.html.erb" do

  it "renders our version of the page" do
    controller.prepend_view_path "app/views/branded"
    render
    expect(rendered.include?("DMPTool logo")).to eql(true)
  end

end
