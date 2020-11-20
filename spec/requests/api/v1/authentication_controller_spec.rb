# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::AuthenticationController, type: :request do

  before(:each) do
    @client = create(:api_client)
  end

  context "actions" do

    describe "POST /api/v1/authenticate" do
      before(:each) do
        @client = create(:api_client)
        @payload = {
          grant_type: "client_credentials",
          client_id: @client.client_id,
          client_secret: @client.client_secret
        }
      end

      it "calls the Api::Jwt::AuthenticationService" do
        Api::V1::Auth::Jwt::AuthenticationService.any_instance.expects(:call).at_most(1)
        post api_v1_authenticate_path, params: @payload.to_json
      end
      it "renders /api/v1/error template if authentication fails" do
        errs = [Faker::Lorem.sentence]
        Api::V1::Auth::Jwt::AuthenticationService.any_instance
                                                 .stubs(:call).returns(nil)
                                                 .stubs(:errors).returns(errs)
        post api_v1_authenticate_path, params: @payload.to_json
        expect(response.code).to eql("401")
        expect(response).to render_template("api/v1/error")
      end
      it "returns a JSON Web Token" do
        token = Api::V1::Auth::Jwt::JsonWebToken.encode(payload: @payload)
        Api::V1::Auth::Jwt::AuthenticationService.any_instance.stubs(:call)
                                                 .returns(token)
        post api_v1_authenticate_path, params: @payload.to_json
        expect(response.code).to eql("200")
        expect(response).to render_template("api/v1/token")
      end
    end

  end

end
