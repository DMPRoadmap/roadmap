class FixColumnNames < ActiveRecord::Migration
  def change
    change_table :answers do |t|
      t.rename :answer_text, :text
    end
    change_table :dmptemplates do |t|
      t.rename :template_desc, :description
      t.rename :template_title, :title
      t.rename :template_published, :published
      t.rename :org_id, :organisation_id
    end
    change_table :plan_sections do |t|
      t.rename :plan_section_at, :at
      t.rename :plan_section_edit, :edit
    end
    change_table :file_types do |t|
      t.rename :file_type_name, :name
    end
    change_table :file_uploads do |t|
      t.rename :file_upload_desc, :description
      t.rename :file_upload_location, :location
      t.rename :file_upload_name, :name
      t.rename :file_upload_title, :title
      t.rename :file_upload_published, :published
      t.rename :file_upload_size, :size
    end
    change_table :guidances do |t|
      t.rename :guidance_file_id, :file_id
      t.rename :guidance_text, :text
      t.rename :org_id, :organisation_id
    end
    change_table :organisation_types do |t|
      t.rename :org_type_name, :name
      t.rename :org_type_desc, :description
    end
    change_table :organisations do |t|
      t.rename :org_abbre, :abbreviation
      t.rename :org_banner_file_id, :banner_file_id
      t.rename :org_domain, :domain
      t.rename :org_desc, :description
      t.rename :org_logo_file_id, :logo_file_id
      t.rename :org_stylesheet_file_id, :stylesheet_file_id
      t.rename :org_name, :name
      t.rename :org_target_url, :target_url
      t.rename :org_type_id, :organisation_type_id
      t.rename :org_wayfless_entite, :wayfless_entity
    end
    change_table :pages do |t|
      t.rename :org_id, :organisation_id
      t.rename :pag_body_text, :body_text
      t.rename :pag_location, :location
      t.rename :pag_menu, :menu
      t.rename :pag_menu_position, :menu_position
      t.rename :pag_public, :public
      t.rename :pag_slug, :slug
      t.rename :pag_target_url, :target_url
      t.rename :pag_title, :title
    end
    change_table :plans do |t|
      t.rename :plan_locked, :locked
    end
    change_table :projects do |t|
      t.rename :project_locked, :locked
      t.rename :project_note, :note
      t.rename :project_title, :title
    end
    change_table :project_partners do |t|
      t.rename :org_id, :organisation_id
    end
    change_table :questions do |t|
      t.rename :question_default_value, :default_value
      t.rename :question_dependency_id, :dependency_id
      t.rename :question_dependency_text, :dependency_text
      t.rename :question_guidance, :guidance
      t.rename :question_order, :number
      t.rename :question_parent_id, :parent_id
      t.rename :question_suggested_answer, :suggested_answer
      t.rename :question_text, :text
      t.rename :question_type, :type
    end
    change_table :sections do |t|
      t.rename :section_desc, :description
      t.rename :section_order, :number
      t.rename :section_title, :title
      t.rename :org_id, :organisation_id
    end
    change_table :themes do |t|
      t.rename :theme_desc, :description
      t.rename :theme_title, :title
    end
    change_table :user_org_roles do |t|
      t.rename :org_id, :organisation_id
    end
    change_table :user_role_types do |t|
      t.rename :user_role_type_desc, :description
      t.rename :user_role_type_name, :name
    end
    change_table :user_statuses do |t|
      t.rename :user_status_desc, :description
      t.rename :user_status_name, :name
    end
    change_table :user_types do |t|
      t.rename :user_type_desc, :description
      t.rename :user_type_name, :name
    end
    change_table :users do |t|
      t.rename :user_email, :email
      t.rename :user_firstname, :firstname
      t.rename :user_last_login, :last_login
      t.rename :user_login_count, :login_count
      t.rename :user_orcid_id, :orcid_id
      t.rename :user_password, :password
      t.rename :user_shibboleth_id, :shibboleth_id
      t.rename :user_surname, :surname
    end
  end
end