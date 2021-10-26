class AddClassnameToStructuredAnswer < ActiveRecord::Migration[4.2]
  def change
    add_column :structured_answers, :classname, :string
  end
end
