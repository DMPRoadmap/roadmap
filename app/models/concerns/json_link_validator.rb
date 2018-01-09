module JSONLinkValidator
  extend ActiveSupport::Concern

  included do
    # Parses a stringified JSON according to validate_links (e.g. [{ link: String, text: String}, ...])
    # param {String} the stringified JSON value
    # Returns an Array of hashes after decoding/validating the stringified JSON passed, otherwise nil
    def parse_links(value)
      return nil unless value.is_a?(String)
      begin
        parsed_value = JSON.parse(value)
        return valid_links?(parsed_value) ? parsed_value : nil
      rescue JSON::ParserError
        nil
      end
    end
    # Validates whether or not the value passed is conforming to [{ link: String, text: String}, ...]
    def valid_links?(value)
      if value.is_a?(Array)
        r = value.all? do |o| 
          o.is_a?(Hash) &&
          o.has_key?('link') &&
          o.has_key?('text') &&
          o['link'].is_a?(String) &&
          o['text'].is_a?(String)
        end
        return r
      end
      false
    end
  end
end