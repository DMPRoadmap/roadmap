class OmniauthCallbacksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  
  setup do
    @schemes = IdentifierScheme.all
    @user = User.first
    
    @callback_uris = {}
    
    # Stub out omniauth provider responses
    OmniAuth.config.test_mode = true
    
    @schemes.each do |scheme|
      @callback_uris[scheme.name] = Rails.application.routes.url_helpers.send(
                                                "user_#{scheme.name.downcase}_omniauth_callback_path")

      OmniAuth.config.mock_auth[:"#{scheme.name.downcase}"] = OmniAuth::AuthHash.new({
        :provider => "#{scheme.name.downcase}",
        :uid => 'foo:bar'
      })
    end
  end
  
  # -------------------------------------------------------------
  test "User is not signed in and valid OAuth2 response does not match a User record in DB: should redirect to registration page" do
    @schemes.each do |scheme|
      post @callback_uris[scheme.name], locale: FastGettext.locale
      
      assert @response.redirect_url.include?(new_user_registration_url), "Expected a redirect to the registration page when the user is not logged in and we received a valid callback from #{scheme.name}"
      
      # make sure that the omniauth identifier is a hidden field on the registration page
      assert_not "#user_identifiers[#{scheme.name}]".nil? 
    end
  end

  # -------------------------------------------------------------
  test "User is not signed in and valid OAuth2 login matches a User record in the DB: should auto-signin and redirect to root page" do
    
    @schemes.each do |scheme|
      @user.firstname = 'Tester'
      @user.surname = 'MacTesting'
      @user.user_identifiers << UserIdentifier.new(identifier_scheme: scheme, 
                                                   identifier: "foo:bar")
      @user.save!
      post @callback_uris[scheme.name]

      ### Until ORCID login becomes supported.
      if scheme.name == 'shibboleth'
        assert [I18n.t('devise.omniauth_callbacks.user.success').gsub('%{kind}', scheme.description).downcase,
                I18n.t('devise.omniauth_callbacks.success').gsub('%{kind}', scheme.description).downcase].include?(flash[:notice].downcase), "Expected a success message when simulating a valid callback from #{scheme.name}"
        assert @response.redirect_url.include?(root_url), "Expected a redirect to the root page, #{root_url}, when omniauth returns with a valid identifier!"
      else
         assert_equal _('Successfully signed in'), flash[:notice], "Expected a success message when simulating a valid callback from #{scheme.name}"
         assert @response.redirect_url.include?(new_user_registration_url), "Expected a redirect to the registration page when the user is not logged in and we received a valid callback from #{scheme.name}"
         assert_not "#user_identifiers[#{scheme.name}]".nil?
      end
    end
  end

  # -------------------------------------------------------------
  test "User is signed in and valid OAuth2 login does not match the current user's record in the DB: should attach the identifier to the user and redirect to the edit profile page" do
    
    @schemes.each do |scheme|
      sign_in @user
      
      post @callback_uris[scheme.name]

      assert_equal _("Your account has been successfully linked to %{scheme}.") % { scheme: scheme.description }, flash[:notice], "Expected a success message when simulating a valid callback from #{scheme.name}"
        
      assert_redirected_to "#{edit_user_registration_path}", "Expected a redirect to the edit profile page, #{edit_user_registration_path}, when omniauth returns with a valid identifier for a user that is already signed in!"
      
      # reload the user record and make sure the omniauth value was attached to their record
      usr = User.find(@user.id)
      assert_equal usr.user_identifiers.find_by(identifier_scheme: scheme).identifier, 'foo:bar'
    end
  end
  
  # -------------------------------------------------------------
  test "An omniauth identifier cannot be tied to multiple accounts" do
    new_account = User.create!(firstname: 'Tester', surname: 'Duplicate', 
                               email: 'tester.duplicate@somewhereelse.org',
                               org: Org.first, accept_terms: true,  
                               password: "password123", password_confirmation: "password123")
                               
    @schemes.each do |scheme|
      @user.user_identifiers << UserIdentifier.new(identifier_scheme: scheme, 
                                                   identifier: "foo:bar")
      sign_in new_account
      
      post @callback_uris[scheme.name]

      assert_equal _("The current #{scheme.description} iD has been already linked to a user with email #{@user.email}"), flash[:alert], "Expected that we could not attach #{scheme.name} to an account if it has already been associated with another account"
        
      assert_redirected_to "#{edit_user_registration_path}", "Expected a redirect to the edit profile page, #{edit_user_registration_path}, when omniauth returns with a valid identifier for a user that is already signed in!"
      
      # reload the user record and make sure the omniauth value NOT attached to their record
      # and still associated with the original account
      @user.reload
      assert_equal @user.user_identifiers.find_by(identifier_scheme: scheme).identifier, 'foo:bar'
      new_account.reload
      assert new_account.user_identifiers.find_by(identifier_scheme: scheme).nil?, "Expected the new account to NOT be associated with the #{scheme.name}"
    end
  end

end
