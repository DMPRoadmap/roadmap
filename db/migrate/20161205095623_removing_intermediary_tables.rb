class RemovingIntermediaryTables < ActiveRecord::Migration
  def change
    # removing intermediary structures

    drop_table :dmptemplates

    change_table :new_phases do |t|
      remove_column :vid
    end
    drop_table :phases
    rename_table :new_phases, :phases

    change_table :new_sections do |t|
      rename_column :new_phase_id, :phase_id

    end
    drop_table :sections
    rename_table :new_sections, :sections

    change_table :new_questions do |t|
      rename_column :new_section_id, :section_id
      remove_column :question_id
    end
    drop_table :questions
    rename_table :new_questions, :questions

    change_table :new_questions_themes do |t|
    end
    drop_table :questions_themes
    rename_table :new_questions_themes, :questions_themes

    change_table :new_answers do |t|
      rename_column :new_plan_id, :plan_id
      rename_column :new_question_id, :question_id
    end
    drop_table :answers
    rename_table :new_answers, :answers

    change_table :question_options do |t|
      rename_column :new_question_id, :question_id
      remove_column :option_id
    end
    drop_table :options

    drop_table :answers_options
    rename_table :new_answers_question_options, :answers_question_options

    change_table :notes do |t|
      rename_column :new_answer_id, :answer_id
    end
    drop_table :comments

    change_table :new_plans do |t|
    end
    drop_table :plans
    rename_table :new_plans, :plans

    change_table :roles do |t|
      rename_column :new_plan_id, :plan_id
    end
  end
end
