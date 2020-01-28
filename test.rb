plan = Plan.find(4351)
org = plan.templates.org
question = plan.template.questions.first
file = File.open('test.json')
data = JSON.load(file)
sds = StructuredDataSchema.create(label: 'test', name: 'test', version: 1, schema: data.to_json, org_id: org.id, object: 'foo')
question.update(structured: true, structured_data_schema: sds)