# frozen_string_literal: true

module Dmptool

  module Controllers

    module Users

      module OmniauthCallbacksController

        # rubocop:disable Layout/FormatStringToken
        # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        def process_omniauth_callback(scheme:)
          # There is occassionally a disconnect between the id of the Scheme
          # when the base controller's dynamic methods were defined and the
          # time this method is called, so reload the scheme
          scheme = IdentifierScheme.find_by(name: scheme.name)

          @provider = provider(scheme: scheme)
          @omniauth = omniauth.with_indifferent_access

          # if the user is already signed in then we are attempting to attach
          # omniauth credentials to an existing account
          if current_user.present? && @omniauth[:uid].present?
            identifier = attach_omniauth_credentials(
              user: current_user, scheme: scheme, omniauth: @omniauth
            )

            if identifier.present?
              msg = format(_("Your account has been successfully linked to %{scheme}."),
                           scheme: @provider)
              redirect_to edit_user_registration_path, notice: msg
            else
              msg = format(_("Unable to link your account to %{scheme}"),
                           scheme: @provider)
              redirect_to edit_user_registration_path, alert: msg
            end

          else
            # Attempt to locate the user via the credentials returned by omniauth
            @user = User.from_omniauth(OpenStruct.new(@omniauth))

            # If we found the user by their omniauth creds then sign them in
            if @user.present?
              flash[:notice] = _("Successfully signed in")
              sign_in_and_redirect @user, event: :authentication

            else
              # Otherwise attempt to locate the user via the email provided in
              # the omniauth creds
              new_user = omniauth_hash_to_new_user(scheme: scheme, omniauth: @omniauth)
              @user = User.where_case_insensitive("email", new_user.email).first

              # If we found the user by email
              if @user.present?
                # sign them in and attach their omniauth credentials to the account
                identifier = attach_omniauth_credentials(
                  user: @user, scheme: scheme, omniauth: @omniauth
                )

                # rubocop:disable Metrics/BlockNesting
                if identifier.present?
                  flash[:notice] = format(_("Successfully signed in with %{scheme}."),
                                          scheme: @provider)
                  sign_in_and_redirect @user, event: :authentication
                end
                # rubocop:enable Metrics/BlockNesting

              else
                # If we could not find a match take them to the account setup page
                redirect_to_registration(scheme: scheme, data: @omniauth)
              end
            end
          end
        end
        # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
        # rubocop:enable Layout/FormatStringToken

        private

        # Return the visual name of the scheme
        def provider(scheme:)
          return _("your institutional credentials") if scheme.name == "shibboleth"

          scheme.description
        end

        # Extract the omniauth info from the request
        def omniauth
          return {} unless request.env.present?

          hash = request.env["omniauth.auth"]
          hash = request.env[:"omniauth.auth"] unless hash.present?
          hash.present? ? hash : request.env
        end

        # rubocop:disable Layout/LineLength
        def redirect_to_registration(scheme:, data:)
          session["devise.#{scheme.name.downcase}_data"] = data
          redirect_to Rails.application.routes.url_helpers.new_user_registration_path,
                      notice: _("It looks like this is your first time logging in. Please verify and complete the information below to finish creating an account.")
        end
        # rubocop:enable Layout/LineLength

        # Attach the omniauth uid to the User
        # rubocop:disable Metrics/CyclomaticComplexity
        def attach_omniauth_credentials(user:, scheme:, omniauth:)
          return false unless user.present? && scheme.present? && omniauth.present?

          ui = Identifier.where(identifier_scheme: scheme, identifiable: user).first
          # If the User exists and the uid is different update it
          ui.update(value: omniauth[:uid]) if ui.present? && ui.value != omniauth[:uid]
          return ui.reload if ui.present?

          Identifier.create(identifier_scheme: scheme, identifiable: user,
                            value: omniauth[:uid])
        end
        # rubocop:enable Metrics/CyclomaticComplexity

        # Convert the incoming omniauth info into a User
        def omniauth_hash_to_new_user(scheme:, omniauth:)
          return nil unless scheme.present? && omniauth.present?

          omniauth_info = omniauth.fetch(:info, {})
          names = extract_omniauth_names(hash: omniauth_info)
          User.new(
            email: extract_omniauth_email(hash: omniauth_info),
            firstname: names.fetch(:firstname, ""),
            surname: names.fetch(:surname, ""),
            org: extract_omniauth_org(scheme: scheme, hash: omniauth_info)
          )
        end

        # Extract the 1st email
        def extract_omniauth_email(hash:)
          hash.present? ? hash.fetch(:email, "").split(";")[0] : nil
        end

        # Find the User names from the omniauth info
        # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        def extract_omniauth_names(hash:)
          return {} unless hash.present?

          out = {
            firstname: hash.fetch(:givenname, hash.fetch(:firstname, "")),
            surname: hash.fetch(:sn, hash.fetch(:surname, hash.fetch(:lastname, "")))
          }
          return out if out[:firstname].present? || out[:surname].present?

          names = hash[:name].split(" ")
          {
            firstname: names[0],
            surname: names.length > 1 ? names[names.length - 1] : nil
          }
        end
        # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

        # Find the Org associated with the omniauth provider
        def extract_omniauth_org(scheme:, hash:)
          return nil unless scheme.present? &&
                            hash.present? &&
                            hash[:identity_provider].present?

          uid = hash[:identity_provider].downcase
          idp = Identifier.where(identifier_scheme: scheme)
                          .where("LOWER(value) = ?", uid).first
          idp.present? ? idp.identifiable : nil
        end

      end

    end

  end

end
