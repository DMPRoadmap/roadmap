class EnsureIndexesInPlace < ActiveRecord::Migration
  def change
    #users_perms
    remove_index :users_perms, name: 'index_users_perms_on_user_id_and_perm_id'
    add_index :users_perms, :user_id
    #user_identifiers
    add_index :user_identifiers, :user_id
    #roles
    add_index :roles, :user_id
    add_index :roles, :plan_id
    #org_token_permissions
    add_index :org_token_permissions, :org_id
    #users
    add_index :users, :org_id
    remove_index :users, :confirmation_token
    remove_index :users, :invitation_token
    remove_index :users, :reset_password_token
    #notes
    add_index :notes, :answer_id
    #guidance_groups
    add_index :guidance_groups, :org_id
    #guidance
    add_index :guidances, :guidance_group_id
    #themes_in_guidance
    add_index :themes_in_guidance, :theme_id
    add_index :themes_in_guidance, :guidance_id
    #annotations
    add_index :annotations, :question_id
    #question_themes
    remove_index :questions_themes, name: 'question_theme_index'
    remove_index :questions_themes, name: 'theme_question_index'
    add_index :questions_themes, :question_id
    #question_options
    add_index :question_options, :question_id
    #answers_question_options
    remove_index :answers_question_options, name: 'answer_question_option_index'
    remove_index :answers_question_options, name: 'question_option_answer_index'
    add_index :answers_question_options, :answer_id
  end
end
