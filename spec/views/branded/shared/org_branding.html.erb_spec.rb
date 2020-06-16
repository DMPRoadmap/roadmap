# frozen_string_literal: true

require "rails_helper"

describe "shared/org_branding.html.erb" do
  before(:each) do
    @org = build(:org, managed: true)
    controller.prepend_view_path "app/views/branded"
  end

  it "renders the Org name if no logo is available" do
    @org.logo = nil
    assign :user, build(:user, org: @org)
    render
    expect(rendered.include?("<h1>#{@org.name}</h1>")).to eql(true)
  end

  it "renders the Org logo if available" do
    # stub the logo method
    logo = OpenStruct.new({ present?: true })
    logo.stubs(:thumb).returns(OpenStruct.new({ url: Faker::Internet.url }))
    @org.stubs(:logo).returns(logo)
    assign :user, build(:user, org: @org)
    render
    expect(rendered.include?("class=\"org-logo\"")).to eql(true)
  end

  it "renders the Signin / Create Account forms" do
    assign :user, build(:user, org: @org)
    render
    expect(rendered.include?("Sign in")).to eql(true)
    expect(response).to render_template(partial: "shared/_sign_in_form")
    expect(rendered.include?("Create account")).to eql(true)
    expect(response).to render_template(partial: "shared/_create_account_form")
  end

end
