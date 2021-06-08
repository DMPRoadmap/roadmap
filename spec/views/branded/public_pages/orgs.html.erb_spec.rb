# frozen_string_literal: true

require "rails_helper"

describe "public_pages/orgs.html.erb" do

  it "renders our version of the page" do
    generate_shibbolized_orgs(3)
    controller.prepend_view_path "app/views/branded"
    assign :orgs, Org.participating
    render
    expect(rendered.include?("Participating Institutions")).to eql(true)
    expect(response).to render_template(partial: "paginable/orgs/_public")
  end

end
