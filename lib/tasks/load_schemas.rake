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
    p = Rails.root.join("config/schemas/main/#{s['path']}")
    f = File.open(p)
    d = JSON.load(f)
    t = d['title']
    ss = MadmpSchema.find_by(classname: s['classname'])
    
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

# Replace classname keys/values to the corresponding schema_id keys/values in loaded schemas
def fix_schemas
  MadmpSchema.all.each do |s|
    j = s.schema # Get the actual JSON schema from the MadmpSchema object
    
    # Find and replace classname values with the corresponding schema_id
    j = JsonPath.for(j).gsub('$..classname') do |v|
      MadmpSchema.find_by(classname: v).id
    end.to_json

    j = j.gsub('classname', 'schema_id') # Replace the "classname" keys with "schema_id" keys
    s.update(schema: j)
  end
end

# Main rake task for loading schemas
task :load_schemas => :environment do
  load_schemas
  fix_schemas
end