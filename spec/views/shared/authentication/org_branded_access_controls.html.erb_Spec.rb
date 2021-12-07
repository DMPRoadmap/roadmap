# frozen_string_literal: true

require 'rails_helper'

describe 'shared/authentication/org_branded_access_controls.html.erb' do
  before(:each) do
    @org = build(:org, managed: true)
  end

  it "renders the Org logo if it's available" do
    # stub the logo method
    # rubocop:disable Style/OpenStructUse
    logo = OpenStruct.new({ present?: true })
    logo.stubs(:thumb).returns(OpenStruct.new({ url: Faker::Internet.url }))
    # rubocop:enable Style/OpenStructUse
    @org.stubs(:logo).returns(logo)
    assign :user, build(:user, org: @org)
    render
    expect(rendered.include?('class="org-logo"')).to eql(true)
  end

  it 'renders the Org name if the logo is not available' do
    @org.logo = nil
    assign :user, build(:user, org: @org)
    render
    expect(rendered.include?("<h1>#{CGI.escapeHTML(@org.name)}</h1>")).to eql(true)
  end

  it 'Renders the sign in and create acount forms' do
    assign :user, build(:user, org: @org)
    render
    expect(rendered.include?('Sign in')).to eql(true)
    expect(response).to render_template(partial: 'shared/authentication/_sign_in_form')
    expect(rendered.include?('Create account')).to eql(true)
    expect(response).to render_template(partial: 'shared/authentication/_create_account_form')
  end
end
