class AddContextToIdentifierSchemes < ActiveRecord::Migration
  def change
    add_column :identifier_schemes, :context, :integer, default: 0, null: false
  end
end
