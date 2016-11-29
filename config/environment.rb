# Load the Rails application.
require File.expand_path('../application', __FILE__)

#init a debugger
Rails.logger = Logger.new(STDOUT)

# Initialize the Rails application.
Rails.application.initialize!

# Devise configuration helper
# ----------------------------------------------------
if !Devise.nil?
  # Check to see what Omniauth providers were registered with Devise
  # Compare them to the entries in the DB and adjust the DB records accordingly
  defined = IdentifierScheme.where(active: true)#.collect{ |scheme| scheme.name }
  registered = Devise.omniauth_providers

  # Deactivate any entries that are not defined in the config/initializers/devise.rb
  defined.each do |scheme|
    unless registered.include?(scheme.name.to_sym)
      Rails.logger.info "Detected an unsupported identifier_scheme, #{scheme.name}, in the DB, deactivating the entry - if this is a mistake add it to your config/initializers/devise.rb"
      scheme.update_attributes(active: false)
    end
  end

  # If an entry was defined in config/initializers/devise.rb but is not in the DB, add it
  diff = registered.reject{ |i| defined.collect{ |d| d.name }.include?(i.to_s) }
  diff.each do |scheme|
    is = IdentifierScheme.find_by(name: scheme.to_s)
    
    if is.nil?
      Rails.logger.info "Detected a new Omniauth provider in config/initializers/devise.rb that is not defined in the DB - adding #{scheme.to_s} to the identifier_schemes table. The new provider will only be available in the user's profile page. To enable it for login, please update the DB accordingly."
      IdentifierScheme.create!({name: scheme.to_s, description: '', active: true, use_for_login: false})

    else
      Rails.logger.warn "Detected an Omniauth provider, #{scheme.to_s}, in config/initializers/devise.rb but it is inactive in the identifier_schemes table!"
    end
  end

else
  Rails.logger.error "Devise was not properly initialized! Please make sure you have defined the config/initializers/devise.rb initializer."
end
