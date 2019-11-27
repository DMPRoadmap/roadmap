require 'rails_helper'

RSpec.describe 'DMPTool custom endpoints to static pages', type: :request do

  it "#ldap_username should be accessible when not logged in" do
    get users_ldap_username_path
    expect(response).to have_http_status(:success)
    expect(response.body.include?("<h1>Forgot email?")).to eql(true)
  end

  context "#ldap_account" do

    it "email/username is not found" do
      post users_ldap_account_path(username: "invalid")
      expect(response.body.include?("We do not recognize the username")).to eql(true)
    end

    it "email/username was found" do
      create(:user, ldap_username: "tester")
      post users_ldap_account_path(username: "tester")
      expect(response.body.include?("The DMPTool Account email associated")).to eql(true)
    end

  end

end
