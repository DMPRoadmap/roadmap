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
      create(:org, :organisation, :shibbolized, managed: true)
    end
  end

  def mock_omniauth_call(scheme, user)

    case scheme
    when "shibboleth"
      # Mock the OmniAuth payload for Shibboleth
      {
        provider: scheme,
        uid: "123ABC",
        info: {
          email: user.email,
          givenname: user.firstname,
          sn: user.surname,
          identity_provider: user.org.org_identifiers.first.identifier
        }
      }

    when "orcid"
      # Moch the Omniauth payload for Orcid
      {
        provider: scheme,
        uid: "ORCID123"
      }
    else
      {
        provider: scheme,
        uid: "testing"
      }
    end
  end

  def mock_blog
    stub_request(:get, "https://blog.dmptool.org/feed").to_return(
      status: 200, body: "", headers: {}
    )
  end

end

# -------------------------------------------------------------
# end DMPTool customization
# -------------------------------------------------------------
