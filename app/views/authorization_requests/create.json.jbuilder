if @error
  json.status 'error'
  json.error @error
else
  json.status @authorization_request.status
  json.error @authorization_request.error
end
