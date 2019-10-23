json.theme @theme.title
json.answers @answers do |a|
  json.id a.id
  if a.question.question_format.option_based
    json.answer a.question_options.pluck(:text)
    json.comment a.text
  else 
    json.answer a.text
  end
  json.created_at a.created_at
  json.question do
    json.id a.question.id
    json.title a.question.text
    json.type a.question.question_format.title
  end
  json.plan do
    json.id a.plan.id
    json.title a.plan.title
  end
  json.research_output do
    json.id a.research_output.id
    json.title a.research_output.abbreviation
  end
end
