# rubocop:todo Security/JSONLoad

desc 'Loads schemas for structured questions in the database'

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
  # Read and parse index.json file
  index_p = Rails.root.join('config/schemas/main/index.json')
  index_f = File.open(index_p)
  schemas = JSON.load(index_f)
  empty_schema_index = 1

  # Iterate over the schemas of the index.json file
  schemas.each do |s|
    # If path is null in the index file, create an empty MadmpSchema
    # and skip the iteration
    # This is used to offset schemas to match existing schemas on the development server
    if s['path'].nil?
      MadmpSchema.create!(
        label: "(empty schema #{empty_schema_index})",
        name: "(empty schema #{empty_schema_index})",
        schema: '{}', org_id: Org.first.id,
        classname: 'empty_schema'
      )
      p "Empty schemas created (total: #{empty_schema_index})"
      empty_schema_index += 1
      next
    end

    # Read, parse and extract useful data from the JSON schema
    p = Rails.root.join("config/schemas/main/#{s['path']}")
    f = File.open(p)
    d = JSON.load(f)
    t = d['title']
    c = s['classname']

    # Search for an existing schema by name/title
    ss = MadmpSchema.find_by(name: t)

    # If the schema doesn't exist, create it
    if ss.nil?
      begin
        ss = MadmpSchema.create!(
          label: t,
          name: t,
          version: 1,
          schema: d.to_json,
          org_id: Org.first.id,
          classname: c
        )
        p "Created new template: #{t} (classname: #{c}, id: #{ss.id})"
      rescue ActiveRecord::RecordInvalid => e
        p "Error while creating #{c} template: #{e.message}"
      end
    # Else, update the existing schema
    else
      ss.update(schema: d.to_json)
      p "UPDATED template (classname: #{c})"
    end

    q = Question.find_by(id: s['question_id'])
    add_schema_to_question(Question.find(s['question_id']), ss) unless q.nil?
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

# Replace classname keys/values with the corresponding schema_id keys/values
def fix_schemas
  MadmpSchema.all.each do |s|
    j = s.schema # Get the actual JSON schema from the MadmpSchema object

    # Find and replace classname values with the corresponding schema_id
    j = JsonPath.for(j).gsub('$..classname') do |v|
      MadmpSchema.find_by(classname: v).id
    end.to_json

    # Replace the "classname" keys with "schema_id" keys
    j = j.gsub('classname', 'schema_id')
    s.update(schema: j)
  end
end

# Main rake task for loading schemas
task load_schemas: :environment do
  load_schemas
  fix_schemas
end
