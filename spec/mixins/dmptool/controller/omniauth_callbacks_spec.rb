require 'rails_helper'

RSpec.describe 'DMPTool custom handler for Omniauth callbacks', type: :controller do

  include Devise::Test::ControllerHelpers

  describe '#process_omniauth_callback' do

    let!(:org) { create(:org, is_other: false) }
    let!(:shibboleth) { create(:identifier_scheme, name: "shibboleth") }
    let!(:orcid) { create(:identifier_scheme, name: "orcid") }

    before do
      OrgIdentifier.create( org: org, identifier_scheme: shibboleth, identifier: "test-org")
      @controller = Users::OmniauthCallbacksController.new
      request.env["devise.mapping"] = Devise.mappings[:user]
    end

    context "user is already signed in" do

      let!(:user) { create(:user, org: org) }

      before do
        sign_in(user)
      end

      context "linking account to shibboleth" do

        before do
          request.env["omniauth.auth"] = mock_omniauth_call("shibboleth", user)
        end

        it "should create the identifier and display success message" do
          get :shibboleth
          expect(flash[:notice]).to eql("Your account has been successfully linked to your institutional credentials.")
          expect(response).to redirect_to("/users/edit")
        end

        it "should update the identifier and display success message" do
          UserIdentifier.create(identifier_scheme: shibboleth, user: user, identifier: "foo")
          get :shibboleth
          expect(flash[:notice]).to eql("Your account has been successfully linked to your institutional credentials.")
          expect(response).to redirect_to("/users/edit")
          expect(user.reload.user_identifiers.first.identifier).not_to eql("foo")
        end
      end

      context "linking account to orcid" do

        before do
          request.env["omniauth.auth"] = mock_omniauth_call("orcid", user)
        end

        it "should create the identifier and display success message" do
          get :orcid
          expect(flash[:notice]).to eql("Your account has been successfully linked to #{orcid.description}.")
          expect(response).to redirect_to("/users/edit")
        end

        it "should update the identifier and display success message" do
          UserIdentifier.create(identifier_scheme: orcid, user: user, identifier: "foo")
          get :orcid
          expect(flash[:notice]).to eql("Your account has been successfully linked to #{orcid.description}.")
          expect(response).to redirect_to("/users/edit")
          expect(user.reload.user_identifiers.first.identifier).not_to eql("foo")
        end

      end

    end

    context "user is NOT signed in but omniauth uid is already registered" do

      let!(:existing_user) { create(:user, org: org) }
      let!(:existing_uid) { create(:user_identifier, user: existing_user,
                                    identifier_scheme: shibboleth, identifier: "123ABC") }
      before do
        request.env["omniauth.auth"] = mock_omniauth_call("shibboleth", existing_user)
      end

      it "should display a success message and sign in" do
        get :shibboleth
        expect(flash[:notice]).to eql("Successfully signed in")
        expect(response).to redirect_to("/")
      end

    end

    context "user is NOT signed in and omniauth uid not recognized" do

      context "user's email was recognized" do

        let!(:existing_user) { create(:user, org: org) }

        context "was able to associate their account with the omniauth uid via their email address" do

          before do
            request.env["omniauth.auth"] = mock_omniauth_call("shibboleth", existing_user)
          end

          it "should display success message and login" do
            get :shibboleth
            expect(flash[:notice]).to eql("Successfully signed in with your institutional credentials.")
            expect(response).to redirect_to("/")
            expect(existing_user.user_identifiers.first.identifier).to eql("123ABC")
          end

        end

        context "was NOT able to associate their account with the omniauth uid or email address" do
          before do
            request.env["omniauth.auth"] = mock_omniauth_call("shibboleth", existing_user)
            existing_user.update_attributes(email: Faker::Internet.unique.safe_email)
          end

          it "should display a warning message and load the finish account creation page" do
            get :shibboleth
            expect(flash[:notice]).to eql("It looks like this is your first time logging in. Please verify and complete the information below to finish creating an account.")
            expect(response).to render_template(:new) #"/users/sign_up")
            expect(existing_user.user_identifiers.length).to eql(0)
          end

        end

      end

    end

  end

end
