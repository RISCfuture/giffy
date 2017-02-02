json.id @authorization_request.id
json.status @authorization_request.status
json.error @authorization_request.error

json.authorization do
  json.team_name @authorization_request.authorization.team_name
end if @authorization_request.authorization
