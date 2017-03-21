class AddLanguageRefToOrganisation < ActiveRecord::Migration
  def change
    add_reference :organisations, :language
  end
end
