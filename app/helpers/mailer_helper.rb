module MailerHelper
  include PermsHelper

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

  # Returns the messaging for the specified role
  def role_text(role)
    if role.administrator?
      {
        type: _('co-owner'),
        placeholder1: _('write and edit the plan in a collaborative manner.'),
        placeholder2: _('You can also grant rights to other collaborators.')
      }
    elsif role.editor?
      {
        type: _('editor'),
        placeholder1: _('write and edit the plan in a collaborative manner.'),
        placeholder2: nil,
      }
    else
      {
        type: _('read-only'),
        placeholder1: _('read the plan and leave comments.'),
        placeholder2: nil,
      }
    end
  end
end
