class AddLanguageToUser < ActiveRecord::Migration
  def change
    add_reference :users, :language
  end
end
