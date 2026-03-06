# Intentionally Vulnerable Ruby/Rails Application
# DO NOT USE IN PRODUCTION - FOR SECURITY TESTING ONLY

require 'sinatra'
require 'json'
require 'yaml'
require 'nokogiri'
require 'open3'
require 'base64'
require 'digest'
require 'open-uri'

# VULNERABILITY: Hardcoded secrets (CWE-798)
JWT_SECRET = 'super_secret_jwt_key_12345'
ADMIN_PASSWORD = 'admin123'
DB_PASSWORD = 'password123'
API_KEY = 'AKIA_FAKE_RUBY_KEY_FOR_TESTING_ONLY'

# VULNERABILITY: Debug mode enabled in production
set :environment, :development
set :show_exceptions, true
set :dump_errors, true

# In-memory user store (simulating database)
USERS = [
  { id: 1, username: 'admin', password: 'hashed_password', email: 'admin@example.com', role: 'admin' },
  { id: 2, username: 'user', password: 'hashed_password', email: 'user@example.com', role: 'user' }
]

# Home page
get '/' do
  <<-HTML
    <html>
    <head><title>Vulnerable Ruby/Rails App</title></head>
    <body>
      <h1>Intentionally Vulnerable Ruby/Rails Application</h1>
      <p>This application contains numerous security vulnerabilities for testing purposes.</p>
      <h2>Available Endpoints:</h2>
      <ul>
        <li>POST /api/login - SQL Injection</li>
        <li>GET /api/exec?cmd=ls - Command Injection</li>
        <li>GET /api/files?filename=test.txt - Path Traversal</li>
        <li>POST /api/upload - Unrestricted File Upload</li>
        <li>GET /api/search?query=test - XSS</li>
        <li>GET /api/proxy?url=http://example.com - SSRF</li>
        <li>POST /api/evaluate - RCE via eval</li>
        <li>POST /api/deserialize - Insecure Deserialization</li>
        <li>DELETE /api/admin/users/:id - Missing Authentication</li>
        <li>GET /api/users/:id - IDOR</li>
        <li>POST /api/parse-xml - XXE Injection</li>
        <li>POST /api/parse-yaml - YAML Deserialization</li>
        <li>POST /api/register - Mass Assignment</li>
        <li>GET /api/debug - Sensitive Data Exposure</li>
        <li>GET /api/redirect?url=http://example.com - Open Redirect</li>
        <li>POST /api/template - Server-Side Template Injection</li>
        <li>GET /api/regex?input=test - ReDoS</li>
        <li>POST /api/session-fixation - Session Fixation</li>
      </ul>
    </body>
    </html>
  HTML
end

# VULNERABILITY: SQL Injection (CWE-89)
post '/api/login' do
  content_type :json
  data = JSON.parse(request.body.read)
  username = data['username'] || ''
  password = data['password'] || ''

  # Vulnerable: String interpolation in SQL query
  query = "SELECT * FROM users WHERE username = '#{username}' AND password = '#{password}'"
  { query: query, vulnerable: true }.to_json
end

# VULNERABILITY: Command Injection (CWE-78)
get '/api/exec' do
  content_type :json
  cmd = params['cmd'] || ''

  # Vulnerable: Direct execution of user input
  output = `#{cmd}`
  { success: true, output: output }.to_json
end

# VULNERABILITY: Path Traversal (CWE-22)
get '/api/files' do
  content_type :json
  filename = params['filename'] || ''

  # Vulnerable: No sanitization of file path
  begin
    content = File.read("./uploads/#{filename}")
    { content: content }.to_json
  rescue => e
    { error: e.message }.to_json
  end
end

# VULNERABILITY: Unrestricted File Upload (CWE-434)
post '/api/upload' do
  content_type :json

  # Vulnerable: No file type validation
  if params['file']
    filename = params['file'][:filename]
    file = params['file'][:tempfile]
    File.open("./uploads/#{filename}", 'wb') do |f|
      f.write(file.read)
    end
    { success: true, path: "./uploads/#{filename}" }.to_json
  else
    { error: 'No file uploaded' }.to_json
  end
end

# VULNERABILITY: Cross-Site Scripting (XSS) (CWE-79)
get '/api/search' do
  query = params['query'] || ''

  # Vulnerable: Reflects user input without sanitization
  "<h1>Search Results for: #{query}</h1>"
end

# VULNERABILITY: Server-Side Request Forgery (SSRF) (CWE-918)
get '/api/proxy' do
  content_type :json
  url = params['url'] || ''

  # Vulnerable: No URL validation
  begin
    content = URI.open(url).read
    { data: content }.to_json
  rescue => e
    { error: e.message }.to_json
  end
end

# VULNERABILITY: Remote Code Execution via eval (CWE-94)
post '/api/evaluate' do
  content_type :json
  data = JSON.parse(request.body.read)
  code = data['code'] || ''

  # Vulnerable: Direct eval of user input
  result = eval(code)
  { result: result }.to_json
end

# VULNERABILITY: Insecure Deserialization (CWE-502)
post '/api/deserialize' do
  content_type :json
  data = request.body.read

  # Vulnerable: Marshal.load on untrusted data
  begin
    obj = Marshal.load(Base64.decode64(data))
    { result: obj }.to_json
  rescue => e
    { error: e.message }.to_json
  end
end

# VULNERABILITY: XML External Entity (XXE) Injection (CWE-611)
post '/api/parse-xml' do
  content_type :json
  xml = request.body.read

  # Vulnerable: XXE enabled
  begin
    doc = Nokogiri::XML(xml) do |config|
      config.noent  # Enable entity expansion (vulnerable)
      config.dtdload  # Load external DTDs (vulnerable)
    end
    { parsed: true, root: doc.root.name }.to_json
  rescue => e
    { error: e.message }.to_json
  end
end

# VULNERABILITY: YAML Deserialization (CWE-502)
post '/api/parse-yaml' do
  content_type :json
  yaml_data = request.body.read

  # Vulnerable: YAML.load can execute arbitrary code
  begin
    parsed = YAML.load(yaml_data)
    { parsed: parsed }.to_json
  rescue => e
    { error: e.message }.to_json
  end
end

# VULNERABILITY: Mass Assignment (CWE-915)
post '/api/register' do
  content_type :json
  data = JSON.parse(request.body.read)

  # Vulnerable: Allows setting 'role' field directly
  new_user = {
    id: USERS.length + 1,
    username: data['username'] || '',
    password: Digest::SHA256.hexdigest(data['password'] || ''),
    email: data['email'] || '',
    role: data['role'] || 'user'  # Attacker can set role=admin
  }

  USERS << new_user
  { success: true, user: new_user }.to_json
end

# VULNERABILITY: Insecure Direct Object Reference (IDOR) (CWE-639)
get '/api/users/:id' do
  content_type :json
  user_id = params['id'].to_i

  # Vulnerable: No authorization check
  user = USERS.find { |u| u[:id] == user_id }
  { user: user }.to_json
end

# VULNERABILITY: Missing Authentication (CWE-306)
delete '/api/admin/users/:id' do
  content_type :json
  user_id = params['id'].to_i

  # Vulnerable: No authentication or authorization required
  USERS.delete_if { |u| u[:id] == user_id }
  { success: true, deleted: user_id }.to_json
end

# VULNERABILITY: Sensitive Data Exposure (CWE-200)
get '/api/debug' do
  content_type :json
  {
    environment: ENV.to_h,
    settings: settings.to_hash,
    jwt_secret: JWT_SECRET,
    admin_password: ADMIN_PASSWORD,
    db_password: DB_PASSWORD,
    users: USERS
  }.to_json
end

# VULNERABILITY: Open Redirect (CWE-601)
get '/api/redirect' do
  url = params['url'] || 'https://example.com'

  # Vulnerable: No validation of redirect URL
  redirect url
end

# VULNERABILITY: Weak Cryptography (CWE-327)
post '/api/hash' do
  content_type :json
  data = JSON.parse(request.body.read)
  password = data['password'] || ''

  # Vulnerable: Using MD5
  hash = Digest::MD5.hexdigest(password)
  { hash: hash, algorithm: 'MD5' }.to_json
end

# VULNERABILITY: Server-Side Template Injection (SSTI) (CWE-1336)
post '/api/template' do
  content_type :json
  data = JSON.parse(request.body.read)
  template = data['template'] || ''

  # Vulnerable: ERB template rendering with user input
  require 'erb'
  renderer = ERB.new(template)
  output = renderer.result(binding)
  { output: output }.to_json
end

# VULNERABILITY: Regular Expression Denial of Service (ReDoS) (CWE-1333)
get '/api/regex' do
  content_type :json
  input = params['input'] || ''

  # Vulnerable: Catastrophic backtracking regex
  regex = /^(a+)+$/
  match = input.match(regex)
  { matched: !match.nil? }.to_json
end

# VULNERABILITY: LDAP Injection (CWE-90)
get '/api/ldap-search' do
  content_type :json
  username = params['username'] || ''

  # Vulnerable: Direct interpolation into LDAP query
  ldap_query = "(&(objectClass=user)(username=#{username}))"
  { query: ldap_query, vulnerable: true }.to_json
end

# VULNERABILITY: Session Fixation (CWE-384)
post '/api/session-fixation' do
  content_type :json
  data = JSON.parse(request.body.read)
  session_id = data['session_id'] || ''

  # Vulnerable: Accepts session ID from user
  session[:id] = session_id
  { success: true, session_id: session_id }.to_json
end

# VULNERABILITY: Hardcoded Credentials (CWE-798)
post '/api/admin-login' do
  content_type :json
  data = JSON.parse(request.body.read)
  password = data['password'] || ''

  # Vulnerable: Hardcoded admin password
  if password == ADMIN_PASSWORD
    { success: true, role: 'admin' }.to_json
  else
    { success: false }.to_json
  end
end

# VULNERABILITY: Information Exposure Through Error Messages (CWE-209)
get '/api/database-connect' do
  content_type :json

  # Vulnerable: Detailed error messages exposed
  begin
    # Simulated database connection
    raise StandardError, "Connection failed: Access denied for user 'root'@'localhost' using password '#{DB_PASSWORD}'"
  rescue => e
    { error: e.message, backtrace: e.backtrace }.to_json
  end
end

# VULNERABILITY: Missing Rate Limiting (CWE-770)
post '/api/brute-force-target' do
  content_type :json
  data = JSON.parse(request.body.read)
  password = data['password'] || ''

  # Vulnerable: No rate limiting, allows brute force
  if password == 'correct_password'
    { success: true }.to_json
  else
    { success: false }.to_json
  end
end

# VULNERABILITY: Insecure Randomness (CWE-330)
get '/api/generate-token' do
  content_type :json

  # Vulnerable: Using predictable random
  token = Digest::MD5.hexdigest(rand.to_s)
  { token: token, algorithm: 'rand()+MD5' }.to_json
end

# VULNERABILITY: Directory Listing (CWE-548)
get '/api/list-directory' do
  content_type :json
  path = params['path'] || './'

  # Vulnerable: Exposes directory structure
  files = Dir.glob("#{path}/*")
  { files: files }.to_json
end

# VULNERABILITY: Use of GET Request Method With Sensitive Query Strings (CWE-598)
get '/api/reset-password' do
  content_type :json
  token = params['token'] || ''
  new_password = params['password'] || ''

  # Vulnerable: Sensitive data in GET parameters (appears in logs)
  { success: true, token: token, password: new_password }.to_json
end

# VULNERABILITY: Insufficient Logging (CWE-778)
post '/api/sensitive-operation' do
  content_type :json
  data = JSON.parse(request.body.read)

  # Vulnerable: No logging of sensitive operations
  # Perform sensitive operation without audit trail
  { success: true }.to_json
end

# VULNERABILITY: Integer Overflow (CWE-190)
get '/api/calculate' do
  content_type :json
  a = params['a'].to_i
  b = params['b'].to_i

  # Vulnerable: No overflow checking
  result = a * b
  { result: result }.to_json
end

# VULNERABILITY: Race Condition (CWE-362)
post '/api/transfer' do
  content_type :json
  data = JSON.parse(request.body.read)
  from = data['from'] || ''
  to = data['to'] || ''
  amount = data['amount'].to_i

  # Vulnerable: No locking, allows race conditions
  # Check balance (time window for race condition)
  sleep(0.1)  # 100ms delay
  # Perform transfer
  { success: true, transferred: amount }.to_json
end

# Start the server
if __FILE__ == $0
  puts "Starting Vulnerable Ruby/Rails Application..."
  puts "WARNING: This application is intentionally vulnerable!"
  puts "Access at: http://localhost:4567"
  set :port, 4567
  set :bind, '0.0.0.0'
end
