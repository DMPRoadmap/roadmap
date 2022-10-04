# frozen_string_literal: true

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
