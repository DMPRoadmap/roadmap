class RemovingIntermediaryTables < ActiveRecord::Migration
  def up
    # removing intermediary structures

    drop_table :dmptemplates

    change_table :new_phases do |t|
      t.remove :vid
    end
    drop_table :phases
    rename_table :new_phases, :phases

    change_table :new_sections do |t|
      t.rename :new_phase_id, :phase_id

    end
    drop_table :sections
    rename_table :new_sections, :sections

    change_table :new_questions do |t|
      t.rename :new_section_id, :section_id
      t.remove :question_id
      t.remove :guidance
    end
    drop_table :questions
    rename_table :new_questions, :questions

    change_table :new_questions_themes do |t|
      t.rename :new_question_id, :question_id
    end
    drop_table :questions_themes
    rename_table :new_questions_themes, :questions_themes

    change_table :new_answers do |t|
      t.rename :new_plan_id, :plan_id
      t.rename :new_question_id, :question_id
    end
    drop_table :answers
    rename_table :new_answers, :answers

    change_table :question_options do |t|
      t.rename :new_question_id, :question_id
      t.remove :option_id
    end
    drop_table :options

    change_table :new_answers_question_options do |t|
      t.rename :new_answer_id, :answer_id
    end
    drop_table :answers_options
    rename_table :new_answers_question_options, :answers_question_options

    change_table :notes do |t|
      t.rename :new_answer_id, :answer_id
    end
    drop_table :comments

    change_table :new_plans do |t|
      t.remove :project_id
    end
    drop_table :plans
    rename_table :new_plans, :plans
    change_table :new_plans_guidance_groups do |t|
      t.rename :new_plan_id, :plan_id
    end
    rename_table :new_plans_guidance_groups, :plans_guidance_groups

    change_table :roles do |t|
      t.rename :new_plan_id, :plan_id
    end

    change_table :annotations do |t|
      t.rename :new_question_id, :question_id
    end
    drop_table :suggested_answers
# Only needed for DMPonline service migration.
#    change_table :users do |t|
#      t.remove :dmponline3
#    end

    #drop_table :projects

    rename_table :organisations, :orgs
    rename_column :guidance_groups, :organisation_id, :org_id
    rename_column :annotations, :organisation_id, :org_id
    rename_column :org_token_permissions, :organisation_id, :org_id
    rename_column :projects, :organisation_id, :org_id
    rename_column :templates, :organisation_id, :org_id
    rename_column :users, :organisation_id, :org_id


    drop_table :projects
    
    drop_table :project_groups
    drop_table :project_guidance
    drop_table :versions
    drop_table :dmptemplates_guidance_groups
    drop_table :plan_sections

  end

  def down
    create_table :dmptemplates
    change_table :phases do |t|
      t.integer :vid
    end
    rename_table :phases, :new_phases
    create_table :phases


    change_table :sections do |t|
      t.rename :phase_id, :new_phase_id
    end
    rename_table :sections, :new_sections
    create_table :sections


    change_table :questions do |t|
      t.rename :section_id, :new_section_id
      t.integer :question_id
    end
    rename_table :questions, :new_questions
    create_table :questions

    change_table :questions_themes do |t|
      t.rename :question_id, :new_question_id
    end
    rename_table :questions_themes, :new_questions_themes
    create_table :questions_themes

    change_table :answers do |t|
      t.rename :plan_id, :new_plan_id
      t.rename :question_id, :new_question_id
    end
    rename_table :answers, :new_answers
    create_table :answers

    change_table :question_options do |t|
      t.rename :question_id, :new_question_id
      t.integer :option_id
    end
    create_table :options

    change_table :answers_question_options do |t|
      t.rename :answer_id, :new_answer_id
    end
    rename_table :answers_question_options, :new_answers_question_options
    create_table :answers_options

    change_table :notes do |t|
      t.rename :answer_id, :new_answer_id
    end
    create_table :comments

    change_table :plans do |t|
    end
    rename_table :plans, :new_plans
    create_table :plans

    change_table :roles do |t|
      t.rename :plan_id, :new_plan_id
    end

    create_table :suggested_answers
    change_table :annotations do |t|
      t.rename :question_id, :new_question_id
    end
    change_table :plans_guidance_groups do |t|
      t.rename :plan_id, :new_plan_id
    end
    rename_table :plans_guidance_groups, :new_plans_guidance_groups
  end
end
