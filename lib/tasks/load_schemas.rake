desc "Loads schemas for structured questions in the database"

# Makes a question structured and links a schema to it
def add_schema_to_question(question, schema)
  question.update(
    question_format: QuestionFormat.find_by(structured: true) || QuestionFormat.create!(
      title: 'Structured',
      description: 'Structured',
      formattype: 9,
      structured: true
    ),
    madmp_schema: schema
  )
end

# Load schemas form an index file
def load_schemas
  index_p = Rails.root.join('config/schemas/main/index.json')
  index_f = File.open(index_p)
  schemas = JSON.load(index_f)
  
  schemas.each do |s|
    p s
    p = Rails.root.join("config/schemas/main/#{s['path']}")
    f = File.open(p)
    d = JSON.load(f)
    t = d['title']
    ss = MadmpSchema.find_by(name: t)
    
    if ss.nil?
      ss = MadmpSchema.create!(label: t, name: t, version: 1, schema: d.to_json, org_id: 276, classname: s['classname'])
    else
      ss.update(schema: d.to_json, classname: s['classname'])
    end

    add_schema_to_question(Question.find(s['question_id']), ss) unless s['question_id'].nil?
  end
end

# Deletes all schemas from the database
def purge_schemas
  qf_id = QuestionFormat.find_by(structured: true)&.id
  return false if qf_id.nil?
  Question.find_by(question_format_id: qf_id).each do |q|
    q.update(schema: nil)
  end
  MadmpSchema.destroy_all
end

# Main rake task for loading schemas
task :load_schemas => :environment do
  load_schemas
end