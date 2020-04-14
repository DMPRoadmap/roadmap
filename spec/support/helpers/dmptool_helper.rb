# frozen_string_literal: true

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
    (1..count).each do
      create(:org, :organisation, :shibbolized, managed: true)
    end
  end

  # rubocop:disable Metrics/MethodLength
  def mock_omniauth_call(scheme, user)
    case scheme
    when "shibboleth"
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

    when "orcid"
      # Moch the Omniauth payload for Orcid
      {
        provider: scheme,
        uid: 4.times.map { Faker::Number.number(l_digits: 4).to_s }.join("-")
      }
    else
      {
        provider: scheme,
        uid: Faker::Lorem.word
      }
    end
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def mock_blog
    xml = <<-XML
    <?xml version="1.0" encoding="UTF-8"?>
    <rss version="2.0">
      <channel>
        <title>#{Faker::Lorem.sentence}</title>
        <item>
          <title>#{Faker::Lorem.sentence}</title>
        </item>
        <item>
          <title>#{Faker::Lorem.sentence}</title>
        </item>
      </channel>
    </rss>
    XML
    stub_request(:get, "https://blog.dmptool.org/feed").to_return(
      status: 200, body: xml.to_s, headers: {}
    )
  end
  # rubocop:enable Metrics/MethodLength

end
