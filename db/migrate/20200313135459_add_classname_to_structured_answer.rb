class AddClassnameToStructuredAnswer < ActiveRecord::Migration
  def change
    add_column :structured_answers, :classname, :string
  end
end
