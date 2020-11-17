class AddLanguageRefToOrganisation < ActiveRecord::Migration[4.2]
  def change
    add_reference :organisations, :language
  end
end
