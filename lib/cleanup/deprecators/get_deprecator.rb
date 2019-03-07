# frozen_string_literal: true

module Cleanup
  module Deprecators

    # Used to deprecate methods with non-idiomatic getter names.
    #
    # There are methods in the code with non-idiomatic method names. Typically,
    # Ruby getters are named as nouns for the attribute they are returning.
    # Prefer User#status over User#get_status.
    #
    class GetDeprecator

      ##
      # Default message to display to developer when deprecated method called.
      MESSAGE = "%<deprecated_method>s is deprecated. "\
                  "Instead, you should use: %<new_method>s. "\
                  "Read #{__FILE__} for more information."

      # Message printed to STDOUT when a deprecated method is called.
      def deprecation_warning(deprecated_method, _message, _backtrace = nil)
        new_method = deprecated_method.to_s.gsub(/^get\_/, '')
        message = format(MESSAGE,
                         deprecated_method: deprecated_method,
                         new_method: new_method)
        Kernel.warn(message)
      end

    end
  end
end
