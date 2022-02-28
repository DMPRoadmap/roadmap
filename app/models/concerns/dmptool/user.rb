# frozen_string_literal: true

module Dmptool
  # DMPTool specific extensions to the User model
  # rubocop:disable Metrics/BlockLength, Metrics/ModuleLength
  module User
    extend ActiveSupport::Concern

    class_methods do
      # ===============
      # = Invitations =
      # ===============

      # Devise Invitable was cumbersome and did not work well with our workflow
      # so we removed that gem but still use the invitation_token field to allow us
      # to create the stub User record and attach it to the Plan.
      #
      # We still want to allow users to be invited though and need to create a stub
      # User record that can be associated with the Plan (via a Role). When the
      # invitation is accepted, the user will have an opportunity to overwrite
      # the stub :firstname, :surname and :org

      # Create the stub User and sent them the invitation email
      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def invite!(inviter:, plan:, context: nil, params: {})
        return nil unless inviter.present? && plan.present? &&
                          params.present? && params[:email].present?

        # Use the assigned org_id or determine which one based on the Inviter type
        org_id = params[:org_id]
        org_id = inviter.is_a?(User) ? inviter.org_id : inviter.user&.org_id unless org_id.present?

        params[:firstname] = 'First' unless params[:firstname].present?
        params[:surname] = 'Last' unless params[:surname].present?
        params[:password] = SecureRandom.uuid unless params[:password].present?
        params[:invitation_token] = SecureRandom.uuid
        params[:invitation_created_at] = Time.now
        params[:invited_by_id] = inviter.id
        params[:invited_by_type] = inviter.class.name
        params[:org_id] = org_id
        params[:invitation_plan_id] = plan&.id

        ::User.transaction do
          invitee = ::User.new(params)
          if invitee.save(params)
            case context
            when 'api'
              UserMailer.new_plan_via_api(recipient: invitee, plan: plan, api_client: inviter)
                        .deliver_now
            when 'template_admin'
              UserMailer.new_plan_via_template(recipient: invitee, sender: inviter, plan: plan)
                        .deliver_now
            else
              UserMailer.invitation(inviter, invitee, plan).deliver_now
            end
            invitee.update(invitation_sent_at: Time.now)
          end
          invitee
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      # ============
      # = Omniauth =
      # ============

      # Load the user based on the scheme and id provided by the Omniauth call
      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      # rubocop:disable Metrics/CyclomaticComplexity
      def from_omniauth(scheme_name:, omniauth_hash:)
        return nil unless scheme_name.present? && omniauth_hash.present? &&
                          omniauth_hash['uid'].present?

        # Find the User by the :uid returned by omniauth
        user = Identifier.by_scheme_name(scheme_name, 'User')
                         .where(value: omniauth_hash['uid'])
                         .first&.identifiable
        return user if user.present?

        omniauth_info = omniauth_hash.fetch('info', {}).to_h
        names = extract_omniauth_names(hash: omniauth_info)
        org = extract_omniauth_org(scheme_name: scheme_name, hash: omniauth_info)
        email = extract_omniauth_email(hash: omniauth_info)

        # Try to find an existing User with the email specified
        user = where('LOWER(email) = ?', email.downcase).first if email.present?
        return user if user.present?

        # We have not seen this user before, so initialize a new one
        user = new(
          email: email,
          firstname: names.fetch(:firstname, ''),
          surname: names.fetch(:surname, ''),
          password: SecureRandom.uuid,
          org_id: org&.id
        )

        # Get the Oauth access token if available
        token = ExternalApiAccessToken.from_omniauth(
          user: user, service: scheme_name, hash: omniauth_hash
        )
        user.external_api_access_tokens = [token] if token.present?
        user
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
      # rubocop:enable Metrics/CyclomaticComplexity

      # Extract the 1st email
      def extract_omniauth_email(hash:)
        return nil unless hash.present?

        emails = hash.fetch('email', '')
        emails = '' if emails.nil?
        emails = emails.split(';')
        emails.any? ? emails.first.downcase : nil
      end

      # Find the User names from the omniauth info
      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def extract_omniauth_names(hash:)
        return {} unless hash.present?

        firstname = hash.fetch('givenname', hash.fetch('firstname', ''))
        surname = hash.fetch('sn', hash.fetch('surname', hash.fetch('lastname', '')))

        # If a full name was provided and no separate firstname and surname fields,
        # attempt to split the full name up
        names = hash.fetch('name', '').split
        names = [names.first, names[1..names.length].join(' ')] if names.any? &&
                                                                   names.length > 1
        firstname = names.first if names.any? && !firstname.present?
        surname = names.last if names.any? && !surname.present?
        { firstname: firstname&.humanize, surname: surname&.humanize }
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      # Find the Org associated with the omniauth provider
      def extract_omniauth_org(scheme_name:, hash:)
        return nil unless scheme_name.present? &&
                          hash.present? &&
                          hash['identity_provider'].present?

        idp = Identifier.by_scheme_name(scheme_name, 'Org')
                        .where('LOWER(value) = ?', hash['identity_provider'].downcase).first
        idp.present? ? idp.identifiable : nil
      end
    end

    included do
      # ===============
      # = Invitations =
      # ===============

      # Devise Invitable was cumbersome and did not work well with our workflow
      # so we removed that gem but still use the invitation_token field to allow us
      # to create the stub User record and attach it to the Plan.
      #
      # We still want to allow users to be invited though and need to create a stub
      # User record that can be associated with the Plan (via a Role). When the
      # invitation is accepted, the user will have an opportunity to overwrite
      # the stub :firstname, :surname and :org

      # Whether or not  the user has an a ctive invitation
      def active_invitation?
        invitation_token.present? && invitation_accepted_at.nil?
      end

      # Updates the accept date.
      def accept_invitation
        return false unless active_invitation?

        update(invitation_accepted_at: Time.now)
      end

      # Attach an OmniAuth UID
      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      def attach_omniauth_credentials(scheme_name:, omniauth_hash:)
        return false unless scheme_name.present? && omniauth_hash.present?

        omniauth_hash = omniauth_hash.with_indifferent_access

        scheme = IdentifierScheme.find_by(name: scheme_name)
        return false unless scheme.present?

        # Create the Oauth access token if available
        token = ExternalApiAccessToken.from_omniauth(
          user: self, service: scheme_name, hash: omniauth_hash
        )
        token.save if token.present?

        ui = identifier_for_scheme(scheme: scheme_name)
        # If the User exists and the uid is different update it
        ui.update(value: omniauth_hash[:uid]) if ui.present? && ui.value != omniauth_hash[:uid]
        return ui.reload if ui.present?

        Identifier.create(identifier_scheme: scheme, identifiable: self,
                          value: omniauth_hash[:uid])
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity

      # ==================
      # = API V2 HELPERS =
      # ==================

      # Fetch the access token for the specified service
      def access_token_for(external_service_name:)
        return nil unless external_service_name.present? && external_api_access_tokens.any?

        tokens = external_api_access_tokens.select do |token|
          token.external_service_name == external_service_name && token.active?
        end
        tokens.first
      end
    end
  end
  # rubocop:enable Metrics/BlockLength, Metrics/ModuleLength
end
