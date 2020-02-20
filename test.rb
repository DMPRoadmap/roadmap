plan = Plan.find(4351)
org = plan.template.org
question = plan.template.questions.first
file = File.open('test.json')
data = JSON.load(file)
sds = StructuredDataSchema.create(label: 'test', name: 'test', version: 1, schema: data.to_json, org_id: org.id, object: 'foo')
qf = QuestionFormat.create(title: "Structured", description: "foo", structured: true)
question.update(question_format: qf, structured_data_schema: sds)