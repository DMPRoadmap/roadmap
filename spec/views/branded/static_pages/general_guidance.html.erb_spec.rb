# frozen_string_literal: true

require "rails_helper"

describe "static_pages/general_guidance.html.erb" do

  it "renders our version of the page" do
    controller.prepend_view_path "app/views/branded"
    render
    expect(rendered.include?("The National Science Foundation (NSF)")).to eql(true)
  end

end
