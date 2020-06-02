json.prettify!

json.array! @users.group_by(&:department).each do |department, users|
  json.code department&.code
  json.name department&.name
  json.id   department&.id
  json.users users.each do |u|
    json.email u.email
  end
end
