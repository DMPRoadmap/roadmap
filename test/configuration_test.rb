require 'test_helper'

class ConfigurationHelper < ActionDispatch::IntegrationTest
  
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
  
end