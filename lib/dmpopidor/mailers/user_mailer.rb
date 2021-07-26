# frozen_string_literal: true

module Dmpopidor

  module Mailers

    module UserMailer

      # commenter - User who wrote the comment
      # plan      - Plan for which the comment is associated to
      # answer - Answer commented on
      # collaborator - User to send the notification to
      # CHANGES
      # Mail is sent with user's locale
      def new_comment(commenter, plan, answer, collaborator)
        if commenter.is_a?(User) && plan.is_a?(Plan)
          owner = plan.owner
          if owner.present? && owner.active?
            @commenter = commenter
            @plan = plan
            @answer = answer
            @collaborator = collaborator
            FastGettext.with_locale current_locale(collaborator) do
              mail(to: collaborator.email, subject:
                _("%{tool_name}: A new comment was added to %{plan_title}") % {
                  :tool_name => Rails.configuration.branding[:application][:name],
                  :plan_title => plan.title
                })
            end
          end
        end
      end

      # CHANGES
      # Changed subject text
      # Mail is sent with user's locale
      def sharing_notification(role, user, inviter:)
        @role = role
        @user = user
        @inviter = inviter

        FastGettext.with_locale current_locale(@user) do
          subject  = d_("dmpopidor", "%{user_name} has shared a Data Management Plan with you in %{tool_name}") % {
              :user_name => @inviter.name(false),
              :tool_name => Rails.configuration.branding[:application][:name]
            }
          mail(to: @role.user.email, subject: subject)
        end
      end

      
      # CHANGES
      # Mail is sent with user's locale
      def permissions_change_notification(role, user)
        @role = role
        @user = user
        if user.active?
          FastGettext.with_locale current_locale(role.user) do
            mail(to: @role.user.email,
                subject: _('Changed permissions on a Data Management Plan in %{tool_name}') %{ :tool_name => Rails.configuration.branding[:application][:name] })
          end
        end
      end


      # CHANGES
      # Mail is sent with user's locale
      def plan_access_removed(user, plan, current_user)
        @user = user
        @plan = plan
        @current_user = current_user
        if user.active?
          FastGettext.with_locale current_locale(@user) do
            mail(to: @user.email,
                 subject: "#{_('Permissions removed on a DMP in %{tool_name}') %{ :tool_name => Rails.configuration.branding[:application][:name] }}")
          end
        end
      end

      # CHANGES
      # Mail is sent with user's locale
      def feedback_notification(recipient, plan, requestor)
        @user = requestor

        if @user.org.present? && recipient.active?
          @org = @user.org
          @plan = plan
          @recipient = recipient

          FastGettext.with_locale current_locale(recipient) do
            mail(to: recipient.email,
                subject: _("%{application_name}: %{user_name} requested feedback on a plan") % {application_name: Rails.configuration.branding[:application][:name], user_name: @user.name(false)})
          end
        end
      end


      # CHANGES
      # Mail is sent with user's locale
      # sender is org's user contact email or no-reply
      def feedback_complete(recipient, plan, requestor)
        @requestor = requestor
        @user      = recipient
        @plan      = plan
        @phase     = plan.phases.first
        if recipient.active?
          FastGettext.with_locale current_locale(recipient) do
            sender = requestor.org.contact_email || Rails.configuration.branding[:organisation][:do_not_reply_email]
            mail(to: recipient.email,
                from: sender,
                subject: _("%{application_name}: Expert feedback has been provided for %{plan_title}") % {application_name: Rails.configuration.branding[:application][:name], plan_title: @plan.title})
          end
        end
      end

      # CHANGES
      # Mail is sent with user's locale
      def plan_visibility(user, plan)
        @user = user
        @plan = plan
        if user.active?
          FastGettext.with_locale current_locale(user) do
            mail(to: @user.email,
                 subject: _('DMP Visibility Changed: %{plan_title}') %{ :plan_title => @plan.title })
          end
        end
      end

      # CHANGES
      # Mail is sent with user's locale
      def admin_privileges(user)
        @user = user
        if user.active?
          FastGettext.with_locale current_locale(@user) do
            mail(to: user.email, subject:
              _('Administrator privileges granted in %{tool_name}') %{ :tool_name => Rails.configuration.branding[:application][:name] })
          end
        end
      end

      ##################
      ## NEW METHODS ###
      ##################
      def anonymization_warning(user)
        @user = user
        @end_date = (@user.last_sign_in_at + 5.years).to_date
        FastGettext.with_locale current_locale(@user) do
          mail(to: @user.email, subject:
            d_('dmpopidor', 'Account expiration in %{tool_name}') %{ :tool_name => Rails.configuration.branding[:application][:name] })
        end
      end
    
      def anonymization_notice(user)
        @user = user
        FastGettext.with_locale current_locale(@user) do
          mail(to: @user.email, subject:
            d_('dmpopidor', 'Account expired in %{tool_name}') %{ :tool_name => Rails.configuration.branding[:application][:name] })
        end
      end
    end
  end

  private

  def current_locale(user)
    user.get_locale.nil? ? FastGettext.default_locale : user.get_locale
  end

end
