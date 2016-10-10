class CustomFailureApp < Devise::FailureApp
  def redirect
    store_location!
    message = warden.message || warden_options[:message]
    
    if message == :timeout
      redirect_to root_path
    else
      super
    end
  end
end