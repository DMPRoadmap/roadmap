# frozen_string_literal: true

require "rails_helper"

describe "devise/registrations/new.html.erb" do

  before(:each) do
    @app_name = ApplicationService.application_name
    controller.prepend_view_path "app/views/branded"
  end

  it "renders correctly when session has shibboleth data" do
    scheme = create(:identifier_scheme, name: "shibboleth")
    org = create(:org, managed: true)
    org.identifiers << create(:identifier, identifiable: org, identifier_scheme: scheme)
    user = build(:user, org: org)
    session["devise.shibboleth_data"] = mock_omniauth_call(scheme.name, user)
    render template: "devise/registrations/new", locals: { resource: user }
    expect(rendered.include?("Sign in or Create account")).to eql(true)
    expect(rendered.include?("Do you have a #{@app_name} account?")).to eql(true)
    expect(rendered.include?("Sign in")).to eql(true)
    expect(rendered.include?("This will link your existing account")).to eql(true)
    expect(response).to render_template(partial: "shared/_sign_in_form")
    expect(rendered.include?("No #{@app_name} account?")).to eql(true)
    expect(rendered.include?("Create account")).to eql(true)
    expect(rendered.include?("This will create an account")).to eql(true)
    expect(response).to render_template(partial: "shared/_create_account_form")
  end

  it "renders correctly when session does NOT have shibboleth data" do
    user = build(:user)
    render template: "devise/registrations/new", locals: { resource: user }
    expect(rendered.include?("Sign in or Create account")).to eql(true)
    expect(rendered.include?("Do you have a #{@app_name} account?")).to eql(false)
    expect(rendered.include?("Sign in")).to eql(true)
    expect(rendered.include?("This will link your existing account")).to eql(false)
    expect(response).not_to render_template(partial: "shared/_sign_in_form")
    expect(rendered.include?("No #{@app_name} account?")).to eql(false)
    expect(rendered.include?("Create account")).to eql(true)
    expect(rendered.include?("This will create an account")).to eql(false)
    expect(response).to render_template(partial: "shared/_create_account_form")
  end

end
