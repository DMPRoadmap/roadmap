# frozen_string_literal: true

require "rails_helper"

describe "paginable/orgs/_public.html.erb" do

  xit "renders our version of the page" do
    generate_shibbolized_orgs(2)
    shib = Org.last
    non_shib = create(:org, managed: true, identifiers: [])

    controller.prepend_view_path "app/views/branded"
    assign :paginable_path_params, { sort_field: "orgs.name", sort_direction: :asc }
    assign :paginable_params, { controller: "paginable/orgs", action: "public" }
    # Paginable is expecting `scope` to be a local not an instance variable
    render partial: "paginable/orgs/public", locals: { scope: Org.participating }
    expect(rendered.include?("Institutional Signin Enabled")).to eql(true)
    expect(rendered.include?(shib.name)).to eql(true)
    expect(rendered.include?(non_shib.name)).to eql(true)
    expect(rendered.scan("fa-check").length).to eql(2)
  end

end
