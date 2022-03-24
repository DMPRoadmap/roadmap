module Features
    FEATURES = {
        change_password: true,
        use_sandbox_logo: false
      }.freeze
  
    def self.enabled?(feature)
        case feature_name.to_sym
        when :change_password
            if Rails.env.development? 
                puts "#### In Development, Allow user to change password"
            else
                puts "#### Disable password change"
            end
        end
    end
end