# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::Auth::Jwt::AuthorizationService do

  before(:each) do
    @token = SecureRandom.uuid
    Api::V1::Auth::Jwt::JsonWebToken.stubs(:decode).returns({ client_id: @token })
    @headers = { "Authorization": "Bearer #{@token}" }
    @service = described_class.new(headers: @headers)
  end

  context "instance methods" do

    it "#initialize(:headers) sets the errors to an empty hash" do
      expect(@service.errors).to eql({})
    end

    it "#call defers to the private #client method" do
      @service.expects(:client).at_least(1)
      @service.call
    end

  end

  context "private methods" do

    before(:each) do
      @client = create(:api_client, client_id: @token)
    end

    describe "#client" do
      it "returns the client if its already set (singleton)" do
        ApiClient.expects(:find_by).at_most(1)
        rslt = @service.send(:client)
        expect(@service.send(:client)).to eql(rslt)
      end
      it "sets client to the one found with the JWT" do
        expect(@service.send(:client)).to eql(@client)
      end
      it "adds 'invalid token' to errors if no client matches the JWT" do
        @service.expects(:decoded_auth_token).returns(nil)
        @service.send(:client)
        expect(@service.errors[:token]).to eql("Invalid token")
      end
    end

    describe "#decoded_auth_token" do
      it "returns the decoded token if its already set (singleton)" do
        rslt = @service.send(:decoded_auth_token)
        expect(@service.send(:decoded_auth_token)).to eql(rslt)
      end
      it "sets the decoded token" do
        expect(@service.send(:decoded_auth_token)[:client_id]).to eql(@token)
      end
      it "adds 'token expired' to errors when a JWT has expired" do
        Api::V1::Auth::Jwt::JsonWebToken.stubs(:decode).raises(JWT::ExpiredSignature)
        expect(@service.send(:decoded_auth_token)).to eql(nil)
        expect(@service.errors[:token]).to eql("Token expired")
      end
    end

    describe "#http_auth_header" do
      it "returns nil if no 'Authorization' header" do
        svc = described_class.new(headers: {})
        expect(svc.send(:http_auth_header)).to eql(nil)
      end
      it "adds 'missing token' to errors if no 'Authorization' header" do
        svc = described_class.new(headers: {})
        svc.send(:http_auth_header)
        expect(svc.errors[:token]).to eql("Missing token")
      end
      it "returns the token portion of the 'Authorization' header" do
        expect(@service.send(:http_auth_header)).to eql(@token)
      end
    end

  end

end
