module FeatureFlagHelper
    def self.enabled?(feature)
        case feature.to_sym

        when :on_sandbox
            if Rails.application.secrets.on_sandbox.to_s == 'true'
                true
            else
                false
            end
        else
            false
        end
    end
end