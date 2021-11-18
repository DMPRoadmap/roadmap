json.prettify!

json.array! @departments.each do |department|
  json.code department.code
  json.name department.name
  json.id   department.id
end
