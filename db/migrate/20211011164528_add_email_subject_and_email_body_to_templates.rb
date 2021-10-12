class AddEmailSubjectAndEmailBodyToTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :templates, :email_subject, :string
    add_column :templates, :email_body, :text
  end
end
