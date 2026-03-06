# Vulnerability Catalog - Vulnerable Ruby/Rails Application

**⚠️ WARNING: This application is intentionally vulnerable. Do NOT use in production!**

## Overview

This application contains **200+ vulnerabilities** across dependencies and source code for testing security remediation tools and processes.

---

## Code Vulnerabilities (SAST)

### Summary: 26 Code-Level Vulnerabilities

| # | Vulnerability | CWE | Location | Severity |
|---|---------------|-----|----------|----------|
| 1 | SQL Injection | CWE-89 | app.rb:72 | Critical |
| 2 | Command Injection | CWE-78 | app.rb:82 | Critical |
| 3 | Path Traversal | CWE-22 | app.rb:93 | High |
| 4 | Unrestricted File Upload | CWE-434 | app.rb:108 | Critical |
| 5 | Cross-Site Scripting (XSS) | CWE-79 | app.rb:122 | High |
| 6 | Server-Side Request Forgery (SSRF) | CWE-918 | app.rb:132 | High |
| 7 | Remote Code Execution (eval) | CWE-94 | app.rb:146 | Critical |
| 8 | Insecure Deserialization (Marshal.load) | CWE-502 | app.rb:157 | Critical |
| 9 | XML External Entity (XXE) Injection | CWE-611 | app.rb:171-174 | High |
| 10 | YAML Deserialization | CWE-502 | app.rb:188 | Critical |
| 11 | Mass Assignment | CWE-915 | app.rb:206 | High |
| 12 | Insecure Direct Object Reference (IDOR) | CWE-639 | app.rb:219 | High |
| 13 | Missing Authentication | CWE-306 | app.rb:229 | Critical |
| 14 | Sensitive Data Exposure | CWE-200 | app.rb:236-243 | Critical |
| 15 | Open Redirect | CWE-601 | app.rb:251 | Medium |
| 16 | Weak Cryptography (MD5) | CWE-327 | app.rb:261 | Medium |
| 17 | Server-Side Template Injection (SSTI) | CWE-1336 | app.rb:273-274 | Critical |
| 18 | Regular Expression DoS (ReDoS) | CWE-1333 | app.rb:284 | Medium |
| 19 | LDAP Injection | CWE-90 | app.rb:295 | High |
| 20 | Session Fixation | CWE-384 | app.rb:306 | High |
| 21 | Hardcoded Credentials | CWE-798 | app.rb:14-17, 317 | Critical |
| 22 | Information Exposure via Error Messages | CWE-209 | app.rb:331-333 | Medium |
| 23 | Missing Rate Limiting | CWE-770 | app.rb:344 | Medium |
| 24 | Insecure Randomness | CWE-330 | app.rb:356 | Medium |
| 25 | Directory Listing | CWE-548 | app.rb:366 | Low |
| 26 | Sensitive Data in GET Parameters | CWE-598 | app.rb:376 | Medium |

---

## Detailed Vulnerability Descriptions

### 1. SQL Injection (CWE-89) - CRITICAL
**Location**: `app.rb:72`
```ruby
query = "SELECT * FROM users WHERE username = '#{username}' AND password = '#{password}'"
```
**Attack**: `username: ' OR '1'='1' --`
**Remediation**: Use parameterized queries with ActiveRecord or prepared statements

---

### 2. Command Injection (CWE-78) - CRITICAL
**Location**: `app.rb:82`
```ruby
output = `#{cmd}`
```
**Attack**: `cmd=ls; rm -rf /`
**Remediation**: Avoid shell execution; use `Open3.capture3` with argument array

---

### 3. Path Traversal (CWE-22) - HIGH
**Location**: `app.rb:93`
```ruby
content = File.read("./uploads/#{filename}")
```
**Attack**: `filename=../../../../etc/passwd`
**Remediation**: Use `File.basename()`, validate paths, use allowlist

---

### 7. Remote Code Execution via eval() (CWE-94) - CRITICAL
**Location**: `app.rb:146`
```ruby
result = eval(code)
```
**Attack**: `code=system('whoami')`
**Remediation**: Never use `eval()` with user input; use safe alternatives

---

### 8. Insecure Deserialization - Marshal.load (CWE-502) - CRITICAL
**Location**: `app.rb:157`
```ruby
obj = Marshal.load(Base64.decode64(data))
```
**Attack**: Craft malicious serialized object for RCE
**Remediation**: Use JSON instead; validate input; never deserialize untrusted data

---

### 9. XXE Injection (CWE-611) - HIGH
**Location**: `app.rb:171-174`
```ruby
doc = Nokogiri::XML(xml) do |config|
  config.noent    # Enable entity expansion (vulnerable)
  config.dtdload  # Load external DTDs (vulnerable)
end
```
**Attack**: Embed DTD to read files or perform SSRF
**Remediation**: Disable external entities:
```ruby
doc = Nokogiri::XML(xml) { |config| config.noent.nonet }
```

---

### 10. YAML Deserialization (CWE-502) - CRITICAL
**Location**: `app.rb:188`
```ruby
parsed = YAML.load(yaml_data)
```
**Attack**: YAML can execute arbitrary Ruby code
**Remediation**: Use `YAML.safe_load()` instead

---

### 17. Server-Side Template Injection (CWE-1336) - CRITICAL
**Location**: `app.rb:273-274`
```ruby
renderer = ERB.new(template)
output = renderer.result(binding)
```
**Attack**: `template=<%= system('whoami') %>`
**Remediation**: Never render templates with user-controlled content

---

### 18. Regular Expression Denial of Service - ReDoS (CWE-1333)
**Location**: `app.rb:284`
```ruby
regex = /^(a+)+$/
match = input.match(regex)
```
**Attack**: `input=aaaaaaaaaaaaaaaaaaaaaa!` (causes catastrophic backtracking)
**Remediation**: Use atomic groups, limit input length, timeout regex matching

---

### 21. Hardcoded Secrets (CWE-798) - CRITICAL
**Locations**: `app.rb:14-17`, `.env:1-92`
```ruby
JWT_SECRET = 'super_secret_jwt_key_12345'
ADMIN_PASSWORD = 'admin123'
```
**Remediation**: Use environment variables, secrets management (Vault, AWS Secrets Manager)

---

## Dependency Vulnerabilities (SCA)

### Expected: 200+ Vulnerabilities

#### Critical Ruby Gems with Known Vulnerabilities

1. **Rails 5.2.3** (2019)
   - Multiple CVEs in ActionPack, ActiveRecord, ActionView
   - SQL injection, XSS, RCE vulnerabilities
   - Expected: 30-50 vulnerabilities across all Rails components

2. **Rack 2.0.7** (2019)
   - CVE-2020-8184 (Path traversal)
   - CVE-2022-30122 (Denial of Service)
   - CVE-2022-30123 (Shell escape sequence injection)

3. **Nokogiri 1.10.3** (2019)
   - CVE-2020-26247 (XXE vulnerability)
   - CVE-2021-30560 (Use after free)
   - CVE-2022-23308 (Integer overflow)
   - Multiple libxml2 vulnerabilities

4. **Loofah 2.2.3** (2019)
   - CVE-2019-15587 (XSS)
   - CVE-2022-23514 (XSS bypass)
   - CVE-2022-23515 (XSS)

5. **JSON 2.2.0** (2019)
   - CVE-2020-10663 (Unsafe object creation vulnerability)

6. **RubyZip 1.2.3** (2019)
   - CVE-2019-16892 (Path traversal)

7. **Devise 4.6.2** (2019)
   - Multiple authentication bypass vulnerabilities
   - Session fixation issues

8. **Carrierwave 1.3.1** (2019)
   - CVE-2021-21305 (Remote code execution)
   - File upload vulnerabilities

9. **Paperclip 6.1.0** (2019)
   - CVE-2020-8162 (Arbitrary file read)
   - Deprecated gem (no longer maintained)

10. **RestClient 2.0.2** (2019)
    - CVE-2015-3448 (Session fixation)
    - CVE-2015-1820 (HTTP header injection)

#### Transitive Dependency Vulnerabilities

- **ActiveSupport, ActiveRecord, ActionPack, ActionView**: 40+ vulnerabilities
- **Sprockets**: 10+ vulnerabilities
- **Rails sub-components**: 30+ vulnerabilities
- **Rack ecosystem**: 15+ vulnerabilities
- **Development dependencies** (RSpec, Factory Bot, etc.): 20+ vulnerabilities

### Remediation Scenarios

#### Scenario 1: Simple Direct Upgrades (30-40 vulnerabilities)
```bash
# Update individual gems
bundle update nokogiri
bundle update rack
bundle update loofah
```

#### Scenario 2: Framework Major Version Upgrade (100+ vulnerabilities)
```bash
# Rails 5.2 → 7.0 (Breaking changes)
gem 'rails', '~> 7.0'
bundle update rails
# Requires code refactoring for API changes
```

#### Scenario 3: Deprecated Package Migration (10-20 vulnerabilities)
```ruby
# Paperclip is deprecated → ActiveStorage
# Replace Paperclip with Rails ActiveStorage
```

#### Scenario 4: Transitive Dependency Resolution (50+ vulnerabilities)
```bash
# Many vulnerabilities fixed by upgrading Rails
# Some require manual version constraints in Gemfile
```

---

## Testing Vulnerabilities

### Scan with Snyk
```bash
cd /path/to/vulnerable-ruby-app
bundle install
snyk test
```

### Scan with Bundler Audit
```bash
gem install bundler-audit
bundle audit check --update
```

### Expected Results
- **200+ open source vulnerabilities**
- **26 code vulnerabilities**
- Multiple critical, high, medium, and low severity issues
- Complex remediation requiring:
  - Simple version bumps
  - Rails framework upgrade with breaking changes
  - Deprecated gem migrations
  - Transitive dependency resolution

---

## Exposed Secrets (.env file)

The `.env` file contains 90+ lines of exposed secrets including:
- Database credentials (PostgreSQL, MySQL)
- AWS access keys
- API keys (Stripe, PayPal, Twilio, SendGrid)
- JWT secrets
- OAuth credentials (Facebook, Google, GitHub, Twitter)
- SMTP credentials
- Redis, MongoDB, Elasticsearch passwords
- Session and encryption keys
- Admin credentials

---

## OWASP Top 10 Coverage

- ✅ **A01:2021** - Broken Access Control (IDOR, Missing Auth)
- ✅ **A02:2021** - Cryptographic Failures (MD5, Hardcoded Secrets)
- ✅ **A03:2021** - Injection (SQL, Command, XXE, LDAP, XPath)
- ✅ **A04:2021** - Insecure Design (Multiple issues)
- ✅ **A05:2021** - Security Misconfiguration (Debug mode, Error messages)
- ✅ **A06:2021** - Vulnerable Components (200+ dependency vulns)
- ✅ **A07:2021** - Identification Failures (Session Fixation, Weak Auth)
- ✅ **A08:2021** - Software/Data Integrity (Deserialization, YAML)
- ✅ **A09:2021** - Logging Failures (Insufficient Logging)
- ✅ **A10:2021** - SSRF (Server-Side Request Forgery)

---

## Disclaimer

This application is for **educational and testing purposes only**. Never deploy to production or expose to the internet.

## License

MIT License - Use at your own risk for security testing and tool validation only.
