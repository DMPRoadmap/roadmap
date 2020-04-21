# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::BaseApiController, type: :request do

  before(:each) do
    @client = create(:api_client)
  end

  context "actions" do

    describe "heartbeat (GET api/v1/heartbeat)" do
      it "skips the authorize_request callback" do
        described_class.new.expects(:authorize_request).at_most(0)
        get api_v1_heartbeat_path
      end
      it "returns a 200 status" do
        get api_v1_heartbeat_path
        expect(response.code).to eql("200")
      end
      it "renders the standard response template" do
        get api_v1_heartbeat_path
        expect(response).to render_template(partial: "api/v1/_standard_response")
      end
    end

  end

  context "private methods" do
    include Mocks::ApiJsonSamples

    before(:each) do
      @controller = described_class.new
    end

    # See the plans_controller_spec.rb for tests of most of this method's
    # callbacks since this controller's only endpoint, :heartbeat, skips them

    describe "#authorize_request" do
      before(:each) do
        @client = create(:api_client)
        struct = OpenStruct.new(headers: {})
        @controller.expects(:request).returns(struct)
      end

      it "calls log_access if the authorization succeeds" do
        auth_svc = OpenStruct.new(call: @client)
        Api::V1::Auth::Jwt::AuthorizationService.expects(:new).returns(auth_svc)
        @controller.expects(:log_access).at_least(1)
        @controller.send(:authorize_request)
      end

      it "sets the client if the authorization succeeds" do
        auth_svc = OpenStruct.new(call: @client)
        Api::V1::Auth::Jwt::AuthorizationService.expects(:new).returns(auth_svc)
        @controller.send(:authorize_request)
        expect(@controller.client).to eql(@client)
      end

      it "renders an UNAUTHORIZED error if the client is not authorized" do
        auth_svc = OpenStruct.new(call: nil)
        Api::V1::Auth::Jwt::AuthorizationService.expects(:new).returns(auth_svc)
        @controller.expects(:render_error).at_least(1)
        @controller.send(:authorize_request)
      end
    end

    describe "#log_access" do
      it "returns false if the client is not set" do
        @controller.expects(:client).returns(nil)
        expect(@controller.send(:log_access)).to eql(false)
      end
      it "returns true if the client is set" do
        @client = create(:api_client)
        @controller.expects(:client).returns(@client)
        expect(@controller.send(:log_access)).to eql(true)
      end
      it "updates the api_client.last_access if client is an ApiClient" do
        @client = create(:api_client)
        time = @client.last_access
        @controller.expects(:client).returns(@client)
        @controller.send(:log_access)
        expect(time).not_to eql(@client.reload.last_access)
      end
      it "updates the users.last_api_access if client is a User" do
        @user = create(:user)
        time = @user.last_api_access
        @controller.expects(:client).returns(@user)
        @controller.send(:log_access)
        expect(time).not_to eql(@user.reload.last_api_access)
      end
    end

    describe "#caller_name" do
      it "returns the caller's IP if the client is nil" do
        ip = Faker::Internet.ip_v4_address
        @controller.expects(:client).returns(nil)
        @controller.expects(:request).returns(OpenStruct.new(remote_ip: ip))
        expect(@controller.send(:caller_name)).to eql(ip)
      end
      it "returns the user name if the client is a User" do
        @user = create(:user)
        @controller.expects(:client).returns(@user)
        expect(@controller.send(:caller_name)).to eql(@user.name(false))
      end
      it "returns the client name if the client is a ApiClient" do
        @client = create(:api_client)
        @controller.expects(:client).returns(@client)
        expect(@controller.send(:caller_name)).to eql(@client.name)
      end
    end

  end

end
