# frozen_string_literal: true

# Helper method to turn system wide feature flag on/off
module FeatureFlagHelper
  def self.enabled?(feature)
    case feature.to_sym

    when :on_sandbox
      Rails.application.secrets.on_sandbox.to_s == 'true'
    else
      false
    end
  end
end
