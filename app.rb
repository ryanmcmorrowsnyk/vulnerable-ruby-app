# Vulnerable Ruby/Rails Application
# 20+ code vulnerabilities, 200+ dependency vulnerabilities

require 'sinatra'
require 'json'

# VULNERABILITY: Hardcoded secrets
JWT_SECRET = 'super_secret_jwt_key_12345'
ADMIN_PASSWORD = 'admin123'

get '/' do
  '<h1>Vulnerable Ruby/Rails App - 200+ Vulnerabilities</h1>'
end

# SQL Injection
post '/api/login' do
  username = params['username']
  query = "SELECT * FROM users WHERE username = '#{username}'"
  {query: query}.to_json
end

# Command Injection
get '/api/exec' do
  cmd = params['cmd']
  output = `#{cmd}`
  {output: output}.to_json
end

# Path Traversal
get '/api/files' do
  filename = params['filename']
  File.read("./uploads/#{filename}")
end
