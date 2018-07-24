module DataCleanup
  module Rules
    # Base class for rules to clean invalid database records
    class Base

      # Description of the rule and how it's fixing the data
      def description
        self.class.name.humanize
      end

      # Run this rule and fix data in the database.
      def call
        raise NotImplementedError, "Please define call() in #{self}"
      end
    end
  end
end
