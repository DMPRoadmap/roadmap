# frozen_string_literal: true

# Logic that ensures that span tags are allowed from dynamic form results
class DynamicFormScrubber < Rails::Html::PermitScrubber
  DYNAMIC_FORM_TAGS = %w[span].freeze

  ALLOWED_TAGS = Rails.application.config.action_view.sanitized_allowed_tags + DYNAMIC_FORM_TAGS

  def initialize
    super
    self.tags = ALLOWED_TAGS
  end
end
