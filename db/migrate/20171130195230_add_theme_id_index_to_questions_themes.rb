class AddThemeIdIndexToQuestionThemes < ActiveRecord::Migration
  def change
    add_index "questions_themes", ["theme_id"], name: "index_questions_themes_on_theme_id", using: :btree
  end
end
