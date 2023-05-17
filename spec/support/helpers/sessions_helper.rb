# frozen_string_literal: true

require_relative 'dmptool_helper'

module Helpers
  module SessionsHelper
    # -------------------------------------------------------------
    # start DMPTool customization
    # Switched so that we are stubbing/mocking User logins via the
    # Devise helper. We are already testing the Capybara login process
    # in the Sessions and Regsitrations tests. This should speed up
    # the tests a bit
    # -------------------------------------------------------------
    include DmptoolHelper

    #   def sign_in(user = :user)
    #     case user
    #     when User
    #       sign_in_as_user(user)
    #     when Symbol
    #       sign_in_as_user(create(:user, org: Org.find_by(is_other: true)))
    #     else
    #       raise ArgumentError, "Invalid argument user: #{user}"
    #     end
    #   end
    #
    #   def sign_in_as_user(user)
    #     # Use the Devise helper to mock a successful user login
    #     login_as(user, scope: :user)
    #     visit root_path
    #   end
    #
    #   def generate_shibbolized_orgs(count)
    #     (1..count).each do
    #       create(:org, :organisation, :shibbolized, managed: true)
    #     end
    #   end

    # rubocop:disable Metrics/MethodLength
    def mock_omniauth_call(scheme, user)
      case scheme
      when 'shibboleth'
        # Mock the OmniAuth payload for Shibboleth
        {
          provider: scheme,
          uid: SecureRandom.uuid,
          info: {
            email: user.email,
            givenname: user.firstname,
            sn: user.surname,
            identity_provider: user.org.identifiers.first.value
          }
        }

      when 'orcid'
        # Moch the Omniauth payload for Orcid
        {
          provider: scheme,
          uid: Array.new(4).map { Faker::Number.number(l_digits: 4).to_s }.join('-')
        }
      else
        {
          provider: scheme,
          uid: Faker::Lorem.word
        }
      end
    end
    # rubocop:enable Metrics/MethodLength

    # -------------------------------------------------------------
    # end DMPTool customization
    # -------------------------------------------------------------
  end
end
