# frozen_string_literal: true

# See : https://github.com/rails/cssbundling-rails/issues/22#issuecomment-923265626
class AssetUrlProcessor
  def self.call(input)
    context = input[:environment].context_class.new(input)
    data = input[:data].gsub(/asset-url\(["']?(.+?)["']?\)/) do |_match|
      "url(#{context.asset_path(::Regexp.last_match(1))})"
    end
    { data: data }
  end
end

Sprockets.register_postprocessor "text/css", AssetUrlProcessor
