# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix missing surname firstname on User
    module User
      class FixMissingSurnameFirstname < Rules::Base

        def description
          "User: Add 'surname' & 'firstname' as values for Users without surname & firstname"
        end

        def call
          ::User.where(firstname: nil).update_all({firstname: 'firstname'})
          ::User.where(surname: nil).update_all({surname: 'surname'})
        end
      end
    end
  end
end
