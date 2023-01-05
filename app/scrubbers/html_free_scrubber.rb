# frozen_string_literal: true

# Logic that ensures that all HTML tags stripped from TinyMCE editor results
class HtmlFreeScrubber < Rails::Html::PermitScrubber
  def initialize
    super
    self.tags = []
  end
end
