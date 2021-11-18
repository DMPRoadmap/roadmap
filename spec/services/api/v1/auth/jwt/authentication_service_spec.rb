# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::Auth::Jwt::AuthenticationService do

  before(:each) do
    @jwt = SecureRandom.uuid
    Api::V1::Auth::Jwt::JsonWebToken.stubs(:encode).returns(@jwt)
  end

  context "instance methods" do

    describe "#initialize(json:)" do
      it "sets errors to empty hash" do
        svc = described_class.new(
          json: {
            grant_type: "client_credentials",
            client_id: Faker::Lorem.word, client_secret: Faker::Lorem.word
          }
        )
        expect(svc.errors).to eql({})
      end
      it "defaults :grant_type to client_credentials" do
        id = Faker::Lorem.word
        svc = described_class.new(
          json: {
            client_id: id,
            client_secret: Faker::Lorem.word
          }
        )
        expect(svc.send(:client_id)).to eql(id)
      end
      it "does not accept invalid :grant_type" do
        svc = described_class.new(
          json: {
            grant_type: Faker::Lorem.word,
            client_id: Faker::Lorem.word,
            client_secret: Faker::Lorem.word
          }
        )
        expect(svc.send(:client_id)).to eql(nil)
      end
      it "accepts client_credentials :grant_type" do
        id = Faker::Lorem.word
        svc = described_class.new(
          json: {
            grant_type: "client_credentials",
            client_id: id,
            client_secret: Faker::Lorem.word
          }
        )
        expect(svc.send(:client_id)).to eql(id)
      end
      it "accepts authorization_code :grant_type" do
        email = Faker::Internet.email
        svc = described_class.new(
          json: {
            grant_type: "authorization_code",
            email: email,
            code: Faker::Lorem.word
          }
        )
        expect(svc.send(:client_id)).to eql(email)
      end
    end

    describe "#call" do
      it "returns null if the client_id is empty" do
        svc = described_class.new(
          json: {
            grant_type: "client_credentials",
            client_id: nil,
            client_secret: Faker::Lorem.word
          }
        )
        expect(svc.call).to eql(nil)
      end

      it "returns null if the client_secret is empty" do
        svc = described_class.new(
          json: {
            grant_type: "client_credentials",
            client_id: Faker::Lorem.word,
            client_secret: nil
          }
        )
        expect(svc.call).to eql(nil)
      end

      it "defers to the private #client method" do
        svc = described_class.new(
          json: {
            grant_type: "client_credentials",
            client_id: Faker::Lorem.word,
            client_secret: Faker::Lorem.word
          }
        )
        svc.expects(:client).at_least(1)
        svc.call
      end

      it "returns nil if the #client method returned nil" do
        svc = described_class.new(
          json: {
            grant_type: "client_credentials",
            client_id: Faker::Lorem.word,
            client_secret: Faker::Lorem.word
          }
        )
        svc.stubs(:client).returns(nil)
        expect(svc.call).to eql(nil)
      end

      it "returns nil if the Client is not an ApiClient or User" do
        org = build(:org)
        svc = described_class.new(
          json: {
            grant_type: "client_credentials",
            client_id: org.name,
            client_secret: org.abbreviation
          }
        )
        svc.stubs(:client).returns(org)
        expect(svc.call).to eql(nil)
      end

      it "returns a JSON Web Token and Expiration Time for ApiClient" do
        client = create(:api_client)
        svc = described_class.new(
          json: {
            grant_type: "client_credentials",
            client_id: client.client_id,
            client_secret: client.client_secret
          }
        )
        svc.stubs(:client).returns(client)
        expect(svc.call).to eql(@jwt)
      end

      it "returns a JSON Web Token and Expiration Time for User" do
        user = create(:user, api_token: SecureRandom.uuid)
        svc = described_class.new(
          json: {
            grant_type: "authorization_code",
            email: user.email,
            code: user.api_token
          }
        )
        svc.stubs(:client).returns(user)
        expect(svc.call).to eql(@jwt)
      end
    end

  end

  context "private methods" do

    describe "#client" do
      before(:each) do
        @service = described_class.new
      end

      it "is a singleton method" do
        client = create(:api_client)
        @service.expects(:authenticate_client).at_most(1).returns(client)
        rslt = @service.send(:client)
        expect(@service.send(:client)).to eql(rslt)
      end
      it "returns nil if no User or ApiClient was authenticated" do
        @service.stubs(:authenticate_user).returns(nil)
        @service.stubs(:authenticate_client).returns(nil)
        rslt = @service.send(:client)
        expect(@service.send(:client)).to eql(rslt)
      end
      it "returns the api_client if a ApiClient was authenticated" do
        client = create(:api_client)
        @service.stubs(:authenticate_client).returns(client)
        expect(@service.send(:client)).to eql(client)
      end
      it "returns the user if a User was authenticated" do
        user = create(:user)
        svc = described_class.new(
          json: {
            grant_type: "authorization_code",
            email: user.email, code: Faker::Lorem.word
          }
        )
        svc.stubs(:authenticate_user).returns(user)
        expect(svc.send(:client)).to eql(user)
      end
      it "adds 'invalid credentials' to errors if nothing authenticated" do
        @service.stubs(:authenticate_user).returns(nil)
        @service.stubs(:authenticate_client).returns(nil)
        @service.send(:client)
        msg = "Invalid credentials"
        expect(@service.errors[:client_authentication]).to eql(msg)
      end
    end

    describe "#authenticate_client" do
      before(:each) do
        @client = create(:api_client)
        @service = described_class.new(
          json: {
            grant_type: "client_credentials",
            client_id: @client.client_id,
            client_secret: @client.client_secret
          }
        )
      end

      it "returns nil if no ApiClient is matched" do
        @client.destroy
        expect(@service.send(:authenticate_client)).to eql(nil)
      end
      it "returns nil if the matching ApiClient did not auth" do
        @client.update(client_secret: SecureRandom.uuid)
        expect(@service.send(:authenticate_client)).to eql(nil)
      end
      it "returns the ApiClient" do
        expect(@service.send(:authenticate_client)).to eql(@client)
      end
    end

    describe "#authenticate_user" do
      before(:each) do
        @user = create(:user, :org_admin, api_token: SecureRandom.uuid)
        @service = described_class.new(
          json: {
            grant_type: "authorization_code",
            email: @user.email,
            code: @user.api_token
          }
        )
      end

      it "returns nil if no User is matched" do
        @user.destroy
        expect(@service.send(:authenticate_user)).to eql(nil)
      end
      it "returns nil if the matching User is inactive" do
        @user.update(active: false)
        expect(@service.send(:authenticate_user)).to eql(nil)
      end
      it "returns nil if the matching User does not have permission" do
        @user.perms.each(&:destroy)
        expect(@service.send(:authenticate_user)).to eql(nil)
      end
      it "returns nil if the client_secret does not match the api_token" do
        @user.update(api_token: SecureRandom.uuid)
        expect(@service.send(:authenticate_user)).to eql(nil)
      end
      it "returns the User" do
        expect(@service.send(:authenticate_user)).to eql(@user)
      end
    end

    describe "#parse_client" do
      before(:each) do
        @service = described_class.new
        @client_id = SecureRandom.uuid
        @client_secret = SecureRandom.uuid
      end

      it "sets the client_id to nil if its is not in JSON" do
        @service.send(
          :parse_client,
          json: {
            client_secret: @client_secret
          }
        )
        expect(@service.send(:client_id)).to eql(nil)
      end
      it "sets the client_secret to nil if its is not in JSON" do
        @service.send(:parse_client, json: { client_id: @client_id })
        expect(@service.send(:client_secret)).to eql(nil)
      end
      it "sets the client_id" do
        @service.send(
          :parse_client,
          json: {
            client_id: @client_id,
            client_secret: @client_secret
          }
        )
        expect(@service.send(:client_id)).to eql(@client_id)
      end
      it "sets the client_secret" do
        @service.send(
          :parse_client,
          json: {
            client_id: @client_id,
            client_secret: @client_secret
          }
        )
        expect(@service.send(:client_secret)).to eql(@client_secret)
      end
    end

    describe "#parse_code" do
      before(:each) do
        @service = described_class.new
        @email = Faker::Internet.email
        @code = SecureRandom.uuid
      end

      it "sets the client_id to nil if :email is not in JSON" do
        @service.send(:parse_code, json: { code: @code })
        expect(@service.send(:client_id)).to eql(nil)
      end
      it "sets the client_secret to nil if :code is not in JSON" do
        @service.send(:parse_code, json: { email: @email })
        expect(@service.send(:client_secret)).to eql(nil)
      end
      it "sets the client_id" do
        @service.send(:parse_code, json: { email: @email, code: @code })
        expect(@service.send(:client_id)).to eql(@email)
      end
      it "sets the client_secret" do
        @service.send(:parse_code, json: { email: @email, code: @code })
        expect(@service.send(:client_secret)).to eql(@code)
      end
    end

  end

end
