class AddLanguageToUser < ActiveRecord::Migration[4.2]
  def change
    add_reference :users, :language
  end
end
