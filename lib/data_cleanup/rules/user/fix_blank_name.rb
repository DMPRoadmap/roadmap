# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix blank user on Note
    module User
      class FixBlankName < Rules::Base

        def description
          "Fix blank Name on User"
        end

        def call
          surname = Set.new(::User.where(surname: [nil,""]))
          firstname = Set.new(::User.where(firstname: [nil,""]))
          both = firstname & surname
          surname = surname ^ both
          firstname = firstname ^ both
          either = firstname | surname
          log("Setting users without orgs to other_org: #{either.map(&:id)}")
          ::User.where(id: both.map(&:id)).update_all(firstname: "PLEASE UPDATE", surname: "YOUR DETAILS")
          ::User.where(id: firstname.map(&:id)).update_all(firstname: "PLEASE UPDATE")
          ::User.where(id: surname.map(&:id)).update_all(surname: "PLEASE UPDATE")
        end
      end
    end
  end
end
