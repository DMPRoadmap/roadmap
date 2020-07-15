# frozen_string_literal: true

module JSONLinkValidator

  # Validates whether or not the value passed is conforming to
  # [{ link: String, text: String}, ...]
  def valid_links?(value)
    if value.is_a?(Array)
      r = value.all? do |o|
        o.is_a?(Hash) && o.key?("link") && o.key?("text") &&
          o["link"].is_a?(String) && o["text"].is_a?(String)
      end
      return r
    end
    false
  end

end
