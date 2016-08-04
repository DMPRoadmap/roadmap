ActionDispatch::Journey::Formatter.module_eval do

  # this overrides formatter in order to solve bug
  # might not be needed, bug is present anyway
  # see https://github.com/rails/rails/issues/12178
  def extract_parameterized_parts(route, options, recall, parameterize = nil)
    parameterized_parts = recall.merge(options)
    keys_to_keep = route.parts.reverse.drop_while { |part|
      !options.key?(part) || (options[part] || recall[part]).nil?
    } | route.required_parts

    # symbolize keys to make sure the right parameters are removed
    (parameterized_parts.symbolize_keys.keys - keys_to_keep.map(&:to_sym)).each do |bad_key|
      parameterized_parts.delete(bad_key)
    end

    if parameterize
      parameterized_parts.each do |k, v|
        parameterized_parts[k] = parameterize.call(k, v)
      end
    end

    parameterized_parts.keep_if { |_, v| v }
    parameterized_parts
  end
end
