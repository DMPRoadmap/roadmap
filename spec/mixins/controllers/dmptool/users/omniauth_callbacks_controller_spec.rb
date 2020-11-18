# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dmptool::Users::OmniauthCallbacksController,
               type: :controller do

  include Devise::Test::ControllerHelpers

  before(:each) do
    @scheme = create(:identifier_scheme, identifier_prefix: nil, name: "shibboleth",
                                         for_authentication: true)
    @org = create(:org, managed: true)
    @entity_id = create(:identifier, identifiable: @org, identifier_scheme: @scheme,
                                     value: SecureRandom.uuid)
    @user = create(:user, org: @org)

    @omniauth_hash = {
      "omniauth.auth": mock_omniauth_call(@scheme.name, @user)
    }.with_indifferent_access
    @controller = Users::OmniauthCallbacksController.new
  end

  it "OmniauthCallbacksController includes our customizations" do
    expect(@controller.respond_to?(:process_omniauth_callback)).to eql(true)
  end

  describe "#process_omniauth_callback" do
    before(:each) do
      request.env["devise.mapping"] = Devise.mappings[:user]
    end

    context "user is already signed in" do
      before do
        sign_in(@user)
      end

      describe "linking account to shibboleth" do
        before do
          request.env["omniauth.auth"] = @omniauth_hash["omniauth.auth"]
          @msg = "Your account has been successfully linked to your institutional credentials."
          @uid = @omniauth_hash["omniauth.auth"]["uid"]
        end

        it "should create the identifier and display success message" do
          get :shibboleth
          expect(flash[:notice]).to eql(@msg)
          expect(response).to redirect_to("/users/edit")
          expect(@user.reload.identifiers.last.value).to eql(@uid)
        end

        it "should update the identifier and display success message" do
          id = create(:identifier, identifier_scheme: @scheme, identifiable: @user,
                                   value: SecureRandom.uuid)
          get :shibboleth
          expect(flash[:notice]).to eql(@msg)
          expect(response).to redirect_to("/users/edit")
          expect(id.reload.value).to eql(@uid)
        end
      end
    end

    describe "user is NOT signed in but omniauth uid is already registered" do
      before do
        @id = create(:identifier, identifier_scheme: @scheme, identifiable: @user,
                                  value: @omniauth_hash["omniauth.auth"]["uid"])
        request.env["omniauth.auth"] = @omniauth_hash["omniauth.auth"]
      end

      it "should display a success message and sign in" do
        get :shibboleth
        expect(flash[:notice].starts_with?("Successfully signed in")).to eql(true)
        expect(response).to redirect_to("/")
        expect(@user.reload.identifiers.last).to eql(@id)
      end
    end

    describe "user is NOT signed in and omniauth uid not recognized" do
      before(:each) do
        request.env["omniauth.auth"] = @omniauth_hash["omniauth.auth"]
        @uid = @omniauth_hash["omniauth.auth"]["uid"]
      end

      context "user's email was recognized" do
        it "should display success message and login" do
          @user.identifiers.destroy_all
          get :shibboleth
          # rubocop:disable Metrics/LineLength
          expect(flash[:notice]).to eql("Successfully signed in with your institutional credentials.")
          # rubocop:enable Metrics/LineLength
          expect(response).to redirect_to("/")
          expect(@user.reload.identifiers.last.value).to eql(@uid)
        end
      end

      context "user's email is not recognized" do
        it "should display a warning message and load the finish account creation page" do
          @user.update(email: Faker::Internet.unique.email)
          get :shibboleth
          # rubocop:disable Metrics/LineLength
          expect(flash[:notice]).to eql("It looks like this is your first time logging in. Please verify and complete the information below to finish creating an account.")
          expect(response).to redirect_to("/users/sign_up")
          expect(@user.identifiers.length).to eql(0)
          expect(session["devise.shibboleth_data"]).to eql(@omniauth_hash["omniauth.auth"])
          # rubocop:enable Metrics/LineLength
        end
      end

    end

  end

  context "private methods" do

    describe "#provider(scheme:)" do
      it "returns 'institutional credentials' if the scheme name is 'shibboleth'" do
        expected = "your institutional credentials"
        expect(@controller.send(:provider, scheme: @scheme)).to eql(expected)
      end
      it "returns the scheme name" do
        @scheme.name = Faker::Lorem.word
        expect(@controller.send(:provider, scheme: @scheme)).to eql(@scheme.description)
      end
    end

    describe "#omniauth" do
      it "returns an empty hash if the Request has no ENV info" do
        @controller.stubs(:request).returns(OpenStruct.new({ env: nil }))
        expect(@controller.send(:omniauth)).to eql({})
      end
      it "finds the 'omniauth.auth' hash in the Request ENV" do
        @controller.stubs(:request).returns(OpenStruct.new({ env: @omniauth_hash }))
        expect(@controller.send(:omniauth)).to eql(@omniauth_hash["omniauth.auth"])
      end
      it "returns the Request ENV if no 'omniauth.auth' is present" do
        hash = { uid: SecureRandom.uuid }
        @controller.stubs(:request).returns(OpenStruct.new({ env: hash }))
        expect(@controller.send(:omniauth)).to eql(hash)
      end
    end

    describe "#redirect_to_registration(data:)" do
      # Tested above because we need the full HTTP Request object to be available
      # to access the session and process a redirect
    end

    describe "#attach_omniauth_credentials(user:, scheme:, omniauth:)" do
      before(:each) do
        @user = create(:user)
      end

      it "returns nil if no :user is present" do
        rslt = @controller.send(:attach_omniauth_credentials, user: nil,
                                                              scheme: @scheme,
                                                              omniauth: @hash)
        expect(rslt).to eql(false)
      end
      it "returns nil if no :scheme is present" do
        rslt = @controller.send(:attach_omniauth_credentials, user: @user,
                                                              scheme: nil,
                                                              omniauth: @hash)
        expect(rslt).to eql(false)
      end
      it "returns nil if no :omniauth hash is present" do
        rslt = @controller.send(:attach_omniauth_credentials, user: @user,
                                                              scheme: @scheme,
                                                              omniauth: nil)
        expect(rslt).to eql(false)
      end
      it "updates the User's Identifier :value" do
        id = create(:identifier, identifiable: @user, identifier_scheme: @scheme)
        hash = { uid: SecureRandom.uuid }
        rslt = @controller.send(:attach_omniauth_credentials, user: @user,
                                                              scheme: @scheme,
                                                              omniauth: hash)
        expect(rslt).to eql(id.reload)
        expect(rslt.value).to eql(hash[:uid])
      end
      it "creates an Identifier for the User" do
        hash = { uid: SecureRandom.uuid }
        rslt = @controller.send(:attach_omniauth_credentials, user: @user,
                                                              scheme: @scheme,
                                                              omniauth: hash)
        expect(rslt.value).to eql(hash[:uid])
      end
    end

    describe "#omniauth_hash_to_new_user(scheme:, omniauth:)" do
      before(:each) do
        @hash = {
          info: {
            name: Faker::Movies::StarWars.character,
            email: Faker::Internet.email,
            identity_provider: @entity_id.value
          }
        }
      end

      it "returns nil if no :scheme is present" do
        rslt = @controller.send(:omniauth_hash_to_new_user, scheme: nil,
                                                            omniauth: @hash)
        expect(rslt).to eql(nil)
      end
      it "returns nil if no :omniauth hash is present" do
        rslt = @controller.send(:omniauth_hash_to_new_user, scheme: @scheme,
                                                            omniauth: nil)
        expect(rslt).to eql(nil)
      end
      it "initializes a new User" do
        rslt = @controller.send(:omniauth_hash_to_new_user, scheme: @scheme,
                                                            omniauth: @hash)
        expect(rslt.new_record?).to eql(true)
        expect(rslt.org).to eql(@org)
        expect(rslt.email).to eql(@hash[:info][:email])
        names = @hash[:info][:name].split
        first = names.length > 1 ? names.first : nil
        expect(rslt.firstname).to eql(first)
        last = names.length > 1 ? names.last : names.first
        expect(rslt.surname).to eql(last)
      end
    end

    describe "#extract_omniauth_email(hash:)" do
      it "returns nil if no email is present in the hash" do
        expect(@controller.send(:extract_omniauth_email, hash: nil)).to eql(nil)
      end
      it "return the email" do
        hash = { email: Faker::Internet.email }
        result = @controller.send(:extract_omniauth_email, hash: hash)
        expect(result).to eql(hash[:email])
      end
      it "returns the 1st email if there are multiples" do
        hash = { email: "#{Faker::Internet.email};#{Faker::Internet.email}" }
        result = @controller.send(:extract_omniauth_email, hash: hash)
        expect(result).to eql(hash[:email].split(";").first)
      end
    end

    describe "#extract_omniauth_names(hash:)" do
      it "returns an empty hash if :hash is not present" do
        expect(@controller.send(:extract_omniauth_names, hash: nil)).to eql({})
      end
      it "handles :givenname" do
        hash = { givenname: Faker::Movies::StarWars.character.split.first }
        result = @controller.send(:extract_omniauth_names, hash: hash)
        expect(result[:firstname]).to eql(hash[:givenname])
      end
      it "handles :firstname" do
        hash = { firstname: Faker::Movies::StarWars.character.split.first }
        result = @controller.send(:extract_omniauth_names, hash: hash)
        expect(result[:firstname]).to eql(hash[:firstname])
      end
      it "handles :lastname" do
        hash = { lastname: Faker::Movies::StarWars.character.split.first }
        result = @controller.send(:extract_omniauth_names, hash: hash)
        expect(result[:surname]).to eql(hash[:lastname])
      end
      it "handles :surname" do
        hash = { surname: Faker::Movies::StarWars.character.split.first }
        result = @controller.send(:extract_omniauth_names, hash: hash)
        expect(result[:surname]).to eql(hash[:surname])
      end
      it "correctly splits :name into first and last" do
        hash = { name: Faker::Movies::StarWars.character }
        result = @controller.send(:extract_omniauth_names, hash: hash)
        names = hash[:name].split
        expect(result[:firstname]).to eql(names.length > 1 ? names.first : nil)
        expect(result[:surname]).to eql(names.last)
      end
    end

    describe "#extract_omniauth_org(scheme:, hash:)" do
      before(:each) do
        @hash = { identity_provider: @entity_id.value_without_scheme_prefix }
      end

      it "returns nil if the :scheme is not present" do
        rslt = @controller.send(:extract_omniauth_org, scheme: nil, hash: @hash)
        expect(rslt).to eql(nil)
      end
      it "returns nil if the :hash is not present" do
        rslt = @controller.send(:extract_omniauth_org, scheme: @scheme, hash: nil)
        expect(rslt).to eql(nil)
      end
      it "returns nil if the :hash has no :identity_provider" do
        rslt = @controller.send(:extract_omniauth_org, scheme: @scheme, hash: {})
        expect(rslt).to eql(nil)
      end
      it "returns nil if there is no matching Org" do
        @hash[:identity_provider] = Faker::Lorem.word
        rslt = @controller.send(:extract_omniauth_org, scheme: @scheme, hash: @hash)
        expect(rslt).to eql(nil)
      end
      it "returns the Org" do
        rslt = @controller.send(:extract_omniauth_org, scheme: @scheme, hash: @hash)
        expect(rslt).to eql(@org)
      end
    end

  end

end
