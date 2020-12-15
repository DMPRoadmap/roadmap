# frozen_string_literal: true

require "rails_helper"

describe "static_pages/help.html.erb" do

  it "renders our version of the page" do
    controller.prepend_view_path "app/views/branded"
    render
    expect(rendered.include?("DMPTool is free for anyone")).to eql(true)
  end

end
