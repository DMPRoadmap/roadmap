module MailerHelper
  include PermsHelper
  def feedback_confirmation_default_subject
    _('%{application_name}: Your plan has been submitted for feedback')
  end

  def feedback_confirmation_default_message
    _('<p>Hello %{user_name}.</p>'\
            '<p>Your plan "%{plan_name}" has been submitted for feedback from an administrator at your organisation. '\
            'If you have questions pertaining to this action, please contact us at %{organisation_email}.</p>')
  end
  
  def feedback_constant_to_text(text, user, plan, org)
    _("#{text}") % {application_name: Rails.configuration.branding[:application][:name],
                    user_name: user.name,
                    plan_name: plan.title,
                    organisation_email: org.contact_email}
  end

  # Returns an unordered HTML list with the permissions associated to the user passed
  def privileges_list(user)
    if user.respond_to?(:perms) && user.perms.respond_to?(:each)
      names = name_and_text
      r= "<ul>"
      user.perms.each do |p|
        r+="<li>#{names[p.name.to_sym]}</li>" if names.has_key?(p.name.to_sym) 
      end
      r+= "</ul>"
    end
  end
end