module Dmpopidor
    module Mailers
      module UserMailer
        # commenter - User who wrote the comment
        # plan      - Plan for which the comment is associated to
        # answer - Answer commented on
        # collaborator - User to send the notification to
        def new_comment(commenter, plan, answer, collaborator)
          if commenter.is_a?(User) && plan.is_a?(Plan)
            owner = plan.owner
            if owner.present? && owner.active?
              @commenter = commenter
              @plan = plan
              @answer = answer
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