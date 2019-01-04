require 'rails_helper'

RSpec.describe 'DMPTool custom handler for Omniauth callbacks', type: :request do

  describe '#process_omniauth_callback' do

    let!(:org) { create(:org, is_other: false) }
    let!(:shibboleth) { create(:identifier_scheme, name: "shibboleth") }

    context "user is already signed in" do

      let!(:user) { create(:user, org: org) }

      before do
        sign_in(user)
      end

      it "should display the proper error when omniauth fails" do
        stub_omniauth_unknown_request_env
        get user_shibboleth_omniauth_callback_path
        expect(flash[:alert]).to eql("Unable to link your account to unknown")
        expect(current_page).to eql(edit_user_registration_path)
      end

      context "linking account to shibboleth" do

        it "should display success message when omniauth worked" do
          stub_omniauth_shibboleth_request_env
          get user_shibboleth_omniauth_callback_path
          expect(flash[:notice]).to eql("Your account has been successfully linked to your institutional credentials.")
          expect(current_page).to eql(edit_user_registration_path)
        end

      end

      context "linking account to orcid" do

        let!(:orcid) { create(:identifier_scheme, name: "orcid") }

        it "should display the proper error when omniauth fails" do

        end

        it "should display success message when omniauth worked" do

        end

      end

    end

    context "user is NOT signed in and omniauth uid is already registered" do

      let!(:existing_user) { create(:user, org: org) }
      let!(:existing_uid) { create(:user_identifier, user: existing_user,
                                    identifier_scheme: shibboleth, identifier: "Testing") }

      it "should display a success message and sign in" do

      end

    end

    context "user is NOT signed in and omniauth uid not recognized" do

      context "user's email was recognized" do

        let!(:existing_user) { create(:user, org: org) }

        context "was able to associate their account with the omniauth uid" do

          it "should display success message and login" do

          end

          it "should associate their account with the omniauth uid" do

          end

        end

        context "was NOT able to associate their account with the omniauth uid" do

          it "should display a warning message and load the finish account creation page" do

          end

        end

      end

      context "user's email was not recognized" do

        it "should display a welcome message and load the finish account creation page" do

        end

      end

    end

  end

  private

  def stub_omniauth_shibboleth_request_env
    module Dmptool
      module Controller
        module OmniauthCallbacks
          include DmptoolHelper::ShibbolethOmniauthEnv
        end
      end
    end
  end

  def stub_omniauth_orcid_request_env
    module Dmptool
      module Controller
        module OmniauthCallbacks
          include DmptoolHelper::OrcidOmniauthEnv
        end
      end
    end
  end

  def stub_omniauth_unknown_request_env
    module Dmptool
      module Controller
        module OmniauthCallbacks
          include DmptoolHelper::UnknownOmniauthEnv
        end
      end
    end
  end


end
