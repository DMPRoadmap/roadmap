# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrgsController, type: :request do

  before(:each) do
    @controller = ::OrgsController.new
    @controller.prepend_view_path "app/views/branded"
    mock_blog
  end

  it "OrgController includes our customizations" do
    expect(@controller.respond_to?(:logos)).to eql(true)
  end

  describe "GET logos" do
    it "page is accessible when not logged in" do
      org = create(:org, managed: true)
      # stub the logo method
      logo = OpenStruct.new({ present?: true })
      logo.stubs(:thumb).returns(OpenStruct.new({ url: Faker::Internet.url }))
      Org.any_instance.stubs(:logo).returns(logo)
      get org_logo_path(org)
      # Request specs are expensive so just check everything in this one test
      expect(response).to have_http_status(:success), "should have received a 200"
      expect(assigns(:user).present?).to eql(true), "should have set @user"
      expect(assigns(:user).org).to eql(org), "should have set @user.org"
      json = JSON.parse(response.body)
      expect(json["org"].present?).to eql(true)
      expect(json["org"]["id"]).to eql(org.id.to_s)
      expect(json["org"]["html"].include?("<div id=\"org-branding\"")).to eql(true)
    end
  end

  describe "POST shibboleth_ds_passthru" do
    before(:each) do
      Rails.application.config.shibboleth_login = "/Shibboleth.sso/Login"
      @shib = create(:identifier_scheme, name: "shibboleth")
      @org = create(:org, managed: true)
    end

    it "redirects back if no Org was specified" do
      post shibboleth_ds_path
      expect(response).to redirect_to(shibboleth_ds_path)
      expect(flash[:notice]).to eql("Please choose an organisation from the list.")
    end
    it "redirects to org_branding if the Org is not shibbolized" do
      post shibboleth_ds_path(id: @org.id)
      expect(response).to have_http_status(:success), "should have received a 200"
      expect(assigns(:user).present?).to eql(true)
      expect(assigns(:user).new_record?).to eql(true)
      expect(response.body.include?("<div id=\"org-branding\"")).to eql(true)
    end
    it "redirects to the shibboleth IdP" do
      id = create(:identifier, identifiable: @org, identifier_scheme: @shib)
      @org = @org.reload
      post shibboleth_ds_path, { id: @org.id }

      location = response.headers["Location"]
      expect(location.include?(Rails.application.config.shibboleth_login)).to eql(true)
      expect(location.include?(request.base_url.gsub("http:", "https:"))).to eql(true)
      passed = location.include?(user_shibboleth_omniauth_callback_url.gsub("http:", "https:"))
      expect(passed).to eql(true)
      expect(location.include?("&entityID=#{id.value}")).to eql(true)
    end
  end

  context "private methods" do

    describe "#convert_params" do
      context "when args is a string" do
        it "when query string like: '?org[id=N]'" do
          hash = { id: Faker::Number.number.to_s }.to_json
          @controller.stubs(:sign_in_params).returns(hash)
          expect(@controller.send(:convert_params)).to eql(JSON.parse(hash))
        end
        it "when query string like: '?shib-ds[org_name=173]&shib-ds[org_id=173]]'" do
          hash = {
            org_name: Faker::Number.number.to_s,
            org_id: Faker::Number.number.to_s
          }.to_json
          @controller.stubs(:sign_in_params).returns(hash)
          expect(@controller.send(:convert_params)).to eql(JSON.parse(hash))
        end
      end
      context "when args is a hash" do
        it "when query string like: '?org[id=N]'" do
          hash = { "id": Faker::Number.number.to_s }.with_indifferent_access
          @controller.stubs(:sign_in_params).returns(hash)
          expect(@controller.send(:convert_params)).to eql(hash)
        end
        it "when query string like: '?shib-ds[org_name=173]&shib-ds[org_id=173]]'" do
          hash = {
            "name": Faker::Number.number.to_s,
            "id": Faker::Number.number.to_s
          }.with_indifferent_access
          @controller.stubs(:sign_in_params).returns(hash)
          expect(@controller.send(:convert_params)).to eql(hash)
        end
      end
    end

  end

end
