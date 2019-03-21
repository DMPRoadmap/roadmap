# frozen_string_literal: true
module DataCleanup
  module Rules
    # Delete note without answer on Note
    module Note
      class DeleteNoteWithoutAnswer < Rules::Base

        def description
          "Note: Delete Note without Answer"
        end

        def call
          ::Note.where(answer_id: nil).delete_all()
        end
      end
    end
  end
end
