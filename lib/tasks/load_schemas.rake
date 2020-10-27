# rubocop:todo Security/JSONLoad

desc 'Loads schemas for structured questions in the database'

DEBUG = false

# Lazy method
def log(message, show = DEBUG)
  p message if show.eql?(true)
end

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
  # empty_schema_index = 1

  # Iterate over the schemas of the index.json file
  # TODO: remove this
  schemas.each do |s|
    # If path is null in the index file, create an empty MadmpSchema
    # and skip the iteration
    # This is used to offset schemas to match existing schemas on the development server
    if s['path'].nil?
      # name = "(empty schema #{empty_schema_index})"
      # MadmpSchema.create!(
      #   label: "(empty schema #{empty_schema_index})",
      #   name: name,
      #   schema: '{}', org_id: Org.first.id,
      #   classname: 'empty_schema'
      # ) unless MadmpSchema.find_by(name: name).present?
      # p "Empty schemas created (total: #{empty_schema_index})"
      # empty_schema_index += 1
      next
    end

    # Read, parse and extract useful data from the JSON schema
    p = Rails.root.join("config/schemas/main/#{s['path']}")
    f = File.open(p)
    d = JSON.load(f)
    t = d['title']
    c = s['classname']
    # i = s['schema-id']

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
        log "CREATED: template #{t} with classname #{c} and id #{ss.id}"
      rescue ActiveRecord::RecordInvalid => e
        log("ERROR: template #{c} is invalid (model validations): #{e.message}", true)
      end
      # Else, update the existing schema
    else
      ss.update(schema: d.to_json)
      log "UPDATED: template #{t} with classname #{c} and id #{ss.id}"
    end

    # TODO: remove this (from index.json too)
    q = Question.find_by(id: s['question_id'])
    add_schema_to_question(Question.find(s['question_id']), ss) unless q.nil?
  end
end

# Deletes all schemas from the database
# TODO: remove this (unused)
def purge_schemas
  qf_id = QuestionFormat.find_by(structured: true)&.id
  return false if qf_id.nil?

  Question.find_by(question_format_id: qf_id).each do |q|
    q.update(schema: nil)
  end

  MadmpSchema.destroy_all
end

def fix_schemas
  MadmpSchema.all.each do |schema|
    begin
      schema.update(schema: MadmpSchema.substitute_names(schema.schema))
    rescue ActiveRecord::RecordNotFound
      log("ERROR: template name substitution failed in #{s.name}: no template named #{v} was found.", true)
      next
    end
  end
end

# Main rake task for loading schemas
task load_schemas: :environment do
  load_schemas
  fix_schemas
end
