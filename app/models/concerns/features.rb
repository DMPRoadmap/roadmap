class Features
    def self.configuration
        # Rails.configuration.features
        # p Rails.configuration.features
        # p "######################"
        Rails.application.secrets.feature_flag
    end

    def self.enabled?(feature)
        p feature
        p Rails.application.secrets
        configuration[feature.to_s].present?
    end
end