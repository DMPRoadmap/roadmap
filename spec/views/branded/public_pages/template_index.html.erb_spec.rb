# frozen_string_literal: true

require "rails_helper"

describe "public_pages/template_index.html.erb" do

  it "renders our version of the page when Funders are available" do
    (1..3).each { create(:template, :publicly_visible) }
    controller.prepend_view_path "app/views/branded"
    assign :templates, Template.all
    render
    expect(rendered.include?("Funder Requirements")).to eql(true)
    expect(rendered.include?("Templates for data management plans")).to eql(true)
    expect(response).to render_template(partial: "paginable/templates/_publicly_visible")
  end

  it "renders our version of the page when NO Funders are available" do
    controller.prepend_view_path "app/views/branded"
    assign :templates, Template.all
    render
    expect(rendered.include?("Funder Requirements")).to eql(true)
    expect(rendered.include?("There are currently no public Templates")).to eql(true)
    expect(response).not_to(
      render_template(partial: "paginable/templates/_publicly_visible")
    )
  end
end
