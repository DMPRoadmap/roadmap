# frozen_string_literal: true

module Cleanup
<<<<<<< HEAD

  module Deprecators

=======
  module Deprecators
>>>>>>> upstream/master
    # Used to deprecate methods that are predicate methods without question mks
    #
    # There are methods in the code with non-idiomatic method names. Typically,
    # Ruby predicates are named as verbs in the infinitive with a question mark.
    #
    class PredicateDeprecator
<<<<<<< HEAD

      ##
      # Default message to display to developer when deprecated method called.
      MESSAGE = "%{deprecated_method}s is deprecated. "\
                  "Instead, you should use: %{new_method}s. "\
                  "Read #{__FILE__} for more information."
=======
      ##
      # Default message to display to developer when deprecated method called.
      MESSAGE = '%{deprecated_method} is deprecated. '\
                'Instead, you should use: %{new_method}. '\
                "Read #{__FILE__} for more information."
>>>>>>> upstream/master

      # Message printed to STDOUT when a deprecated method is called.
      def deprecation_warning(deprecated_method, _message, _backtrace = nil)
        new_method = "#{deprecated_method}?"
<<<<<<< HEAD
        message = MESSAGE % { deprecated_method: deprecated_method,
                              new_method: new_method }
        Kernel.warn(message)
      end

    end

  end

=======
        message = format(MESSAGE, deprecated_method: deprecated_method, new_method: new_method)
        Kernel.warn(message)
      end
    end
  end
>>>>>>> upstream/master
end
