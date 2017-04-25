class CombineQuestionGuidanceAndSuggestedAnswersIntoAnnotations < ActiveRecord::Migration
  def change
    # create table for annotations
    create_table :annotations do |t|
      t.integer "question_id"
      t.integer "org_id"
      t.text    "text"
      t.column :type, :integer, default: 0, null: false
      t.timestamps
    end

    # migrate data from suggested_answers
    SuggestedAnswer.all.each do |sa|
      a = Annotation.new
      a.question_id = sa.question_id
      a.org_id = sa.org_id
      a.text = sa.text
      a.example_answer!
      a.save!
    end
    # migrate data from question.guidance
    Question.includes(section: [phase: [:template]]).all.each do |q|
      if q.guidance.present?
        a = Annotation.new
        a.question_id = q.id
        if q.section.modifiable?
          a.org_id = q.section.phase.template.org_id
        else
          a.org_id = Template.where(dmptemplate_id: q.section.phase.template.customization_of).first.org_id
        end
        a.text = q.guidance
        a.guidance!
        a.save
      end
    end

    delete_table :suggested_answers
    remove_column :question, :guidance
  end
end
