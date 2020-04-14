# frozen_string_literal: true

require "rails_helper"

describe "paginable/templates/_publicly_visible.html.erb" do

  it "renders our version of the page" do
    org = create(:org, :funder)
    2.times { create(:template, :published, org: org) }
    controller.prepend_view_path "app/views/branded"
    assign :paginable_path_params, { sort_field: "templates.title", sort_direction: :asc }
    assign :paginable_params, { controller: "paginable/orgs", action: "public" }
    # Paginable is expecting `scope` to be a local not an instance variable
    render partial: "paginable/templates/publicly_visible", locals: { scope: Template.all }
    expect(rendered.include?("Template")).to eql(true)
    expect(rendered.include?("Funder")).to eql(true)
    Template.all.each { |t| expect(rendered.include?(t.title)).to eql(true) }
  end

end
