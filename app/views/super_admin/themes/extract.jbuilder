json.theme @theme.title
json.answers @theme.answers do |a|
  json.id a.id
  json.answer a.text
  json.question do
    json.id a.question.id
    json.title a.question.text
    json.type a.question.question_format.title
  end
  json.plan do
    json.id a.plan.id
    json.title a.plan.title
  end
end
