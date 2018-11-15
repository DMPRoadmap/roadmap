# frozen_string_literal: true

module Dmptool::Controller::Users

  # GET /users/:id/ldap_username
  def ldap_username
    skip_authorization
    #render '/users/ldap_username'
  end

  def ldap_account
    skip_authorization
    @user = User.where(ldap_username: params[:username]).first
    if @user.present?
      render(json: {
             code: 1,
             email: @user.email,
             msg: _("The DMPTool Account email associated with this username is #{@user.email}"),
      })
    else
      render(json: {
             code: 0,
             email: '',
             msg: _("We do not recognize the username %{username}. Please try again or contact us if you have forgotten the username and email for your existing DMPTool account.") % { username: params[:username] }
      })
    end
  end

end
