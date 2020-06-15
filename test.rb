qf = QuestionFormat.create(title: "Structured", description: 'Structured question', structured: true)
schemas_dir = File.join(Rails.root, 'config', 'schemas')
Dir.glob("#{schemas_dir}/*.json") do |path|
  f = File.open(path)
  d = JSON.load(f)
  n = File.basename(path, '.json')
  MadmpSchema.create(label: n, name: n, version: 1, schema: d.to_json, org_id: nil, classname: nil)
end
Question.find(19051).update(question_format: qf, madmp_schema: MadmpSchema.find_by(name: 'simple'))
Question.find(19052).update(question_format: qf, madmp_schema: MadmpSchema.find_by(name: 'occ_simple'))
Question.find(19053).update(question_format: qf, madmp_schema: MadmpSchema.find_by(name: 'occ_struct'))