# frozen_string_literal: true

module Dmptool

  module Controller

    module Users

      # GET /users/:id/ldap_username
      def ldap_username
        skip_authorization
      end

      def ldap_account
        skip_authorization
        @user = User.where(ldap_username: params[:username]).first
        if @user.present?
          # rubocop:disable LineLength
          render(
            json: {
              code: 1,
              email: @user.email,
              msg: _("The DMPTool Account email associated with this username is #{@user.email}")
            }
          )
          # rubocop:enable LineLength
        else
          # rubocop:disable LineLength
          render(
            json: {
              code: 0,
              email: "",
              msg: _("We do not recognize the username %{username}. Please try again or contact us if you have forgotten the username and email for your existing DMPTool account.") % {
                username: params[:username]
              }
            }
          )
          # rubocop:enable LineLength
        end
      end

    end

  end

end
