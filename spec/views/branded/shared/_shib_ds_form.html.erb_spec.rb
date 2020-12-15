# frozen_string_literal: true

require "rails_helper"

describe "shared/_shib_ds_form.html.erb" do
  before(:each) do
    create(:identifier_scheme, name: "shibboleth", identifier_prefix: nil,
                               for_orgs: true, for_authentication: true)
    generate_shibbolized_orgs(3)
    controller.prepend_view_path "app/views/branded"
  end

  it "renders the Org Selector" do
    render
    expect(rendered.include?("Look up your institution here")).to eql(true)
    expect(rendered.include?("Go")).to eql(true)
    expect(response).to render_template(partial: "shared/org_selectors/_local_only")
  end

  it "does not render the Selection List if there are less than 10 Orgs" do
    render
    expect(rendered.include?("full list of participating institutions")).to eql(false)
  end

  it "renders the Selection List if there are more than 10 Orgs" do
    generate_shibbolized_orgs(11)
    render
    expect(rendered.include?("full list of participating institutions")).to eql(true)
    expect(rendered.include?(Org.participating.first.name)).to eql(true)
    expect(rendered.include?(Org.participating.last.name)).to eql(true)
  end

  it "renders the link to create an account" do
    render
    expect(rendered.include?("Create an account with any email address")).to eql(true)
  end

end
