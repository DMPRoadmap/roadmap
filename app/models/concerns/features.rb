class Features
    def self.configuration
        Rails.configuration.features
    end

    def self.enabled?(feature)
        !!configuration[feature.to_s]
    end
end