# frozen_string_literal: true

require "rails_helper"

describe "shared/authentication/_sign_in_form.html.erb" do

  include SessionsHelper

  it "renders the form" do
    Rails.configuration.x.recaptcha.enabled = true

    assign :resource, User.new
    render
    expect(rendered.include?("Sign in with your email and password")).to eql(true)
    expect(rendered.include?("id=\"sign_in_form\"")).to eql(true)
    expect(rendered.include?("id=\"signin_user_email\"")).to eql(true)
    expect(rendered.include?("id=\"signin_user_password\"")).to eql(true)
    expect(rendered.include?("Forgot password?")).to eql(true)
    expect(rendered.include?("id=\"remember_email\"")).to eql(true)
    expect(rendered.include?("id=\"signin_user_shibboleth_id\"")).to eql(false)
    expect(rendered.include?("Sign in")).to eql(true)
  end

  it "renders properly if part of a new user Omniauth workflow" do
    scheme = create(:identifier_scheme, name: "shibboleth")
    org = create(:org, managed: true)
    org.identifiers << create(:identifier, identifiable: org, identifier_scheme: scheme)
    user = build(:user, org: org)
    assign :resource, user
    session["devise.shibboleth_data"] = mock_omniauth_call(scheme.name, user)
    render

    expect(rendered.include?("Sign in with your email and password")).to eql(true)
    expect(rendered.include?("id=\"sign_in_form\"")).to eql(true)
    expect(rendered.include?(user.email)).to eql(true)
    expect(rendered.include?("id=\"signin_user_password\"")).to eql(true)
    expect(rendered.include?("Forgot password?")).to eql(true)
    expect(rendered.include?("id=\"remember_email\"")).to eql(true)
    expect(rendered.include?("id=\"signin_user_shibboleth_id\"")).to eql(true)
    expect(rendered.include?("Sign in")).to eql(true)
  end

end
