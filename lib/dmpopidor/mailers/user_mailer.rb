module Dmpopidor
  module Mailers
    module UserMailer
      # Mail is sent to the collaborators instead of owner
      # commenter - User who wrote the comment
      # plan      - Plan for which the comment is associated to
      # collaborator - Collaborator to whom the email is sent
      def new_comment(commenter, plan, collaborator)
        if commenter.is_a?(User) && plan.is_a?(Plan)
          owner = plan.owner
          if owner.present? && owner.active?
            @commenter = commenter
            @plan = plan
            @collaborator = collaborator
            FastGettext.with_locale FastGettext.default_locale do
              mail(to: collaborator.email, subject:
                _('%{tool_name}: A new comment was added to %{plan_title}') %{ :tool_name => Rails.configuration.branding[:application][:name], :plan_title => plan.title })
            end
          end
        end
      end
    end
  end
end
