# -------------------------------------------------------------
# start DMPTool customization
# -------------------------------------------------------------

module DmptoolHelper

  def access_sign_in_options_modal
    click_on "Sign in"
  end

  def access_sign_in_modal
    access_sign_in_options_modal
    click_on "Email address"
  end

  def access_create_account_modal
    access_sign_in_options_modal
    click_on "Create account with email address"
  end

  def access_shib_ds_modal
    access_sign_in_options_modal
    click_on "Your institution"
  end

  def generate_shibbolized_orgs(count)
    (1..count).each do |idx|
      create(:org, :organisation, :shibbolized, is_other: false)
    end
  end

  def mock_omniauth_call(scheme, user)

    case scheme
    when "shibboleth"
      # Mock the OmniAuth payload for Shibboleth
      {
        "uid": "123ABC",
        "info": {
          "email": user.email,
          "givenname": user.firstname,
          "sn": user.surname,
          "identity_provider": user.org.org_identifiers.first.identifier
        }
      }

    when "orcid"
      # Moch the Omniauth payload for Orcid
      {
        "uid": "ORCID123"
      }
    else
      {}
    end
  end

  module ShibbolethOmniauthEnv

    def request
      OpenStruct.new({
        "omniauth.auth": mock_omniauth_call("shibboleth", current_user)
      })
    end

  end

  module OrcidOmniauthEnv

    def request
      OpenStruct.new({
        "omniauth.auth": mock_omniauth_call("orcid", current_user)
      })
    end

  end

  module UnknownOmniauthEnv

    def request
      OpenStruct.new({
        "omniauth.auth": mock_omniauth_call("unknown", current_user)
      })
    end

  end

end

# -------------------------------------------------------------
# end DMPTool customization
# -------------------------------------------------------------
