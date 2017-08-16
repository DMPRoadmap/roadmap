require 'test_helper'

class ConfigurationTest < ActionDispatch::IntegrationTest
  
  # --------------------------------------------------------------------
  test "Make sure that all of the example YAML files have been setup properly" do
    # Check for YAML configs
    ['database.yml', 'branding.yml', 'secrets.yml'].each do |yml|
      assert File.exist?("./config/#{yml}"), "Was expecting to find ./config/#{yml}"
    end
    
    # Check for initializers
    ['contact_us.rb', 'devise.rb', 'recaptcha.rb', 'wicked_pdf.rb'].each do |rb|
      assert File.exist?("./config/initializers/#{rb}"), "Was expecting to find ./config/initializers/#{rb}"
    end
  end 
  
  # --------------------------------------------------------------------
  test "Make sure that the config/branding.yml contains the managing Org's info" do
    abbr = Rails.configuration.branding[:organisation][:abbreviation]
    assert_not abbr.nil?, "expected the config/branding.yml to define the managing Org's abbreviation in organisation.abbreviation!"
    assert_not Org.find_by(abbreviation: abbr).nil?, "Was expecting the organisation.abbreviation listed in config/branding.yml, '#{abbr}', to match the one from db/seeds.rb, '#{Org.first.abbreviation}'"
  end
end