# Vulnerable Ruby/Rails Application

**⚠️ WARNING: This application is intentionally vulnerable and should NEVER be deployed to production!**

This is an intentionally vulnerable Ruby/Rails application (using Sinatra for simplicity) designed for testing security remediation tools, SAST/SCA scanners, and security training.

## 🎯 Purpose

This application demonstrates:
- **200+ open source dependency vulnerabilities** requiring complex remediation
- **26 code-level security vulnerabilities** covering OWASP Top 10
- Realistic vulnerable code patterns found in real-world Ruby applications
- Various remediation scenarios (simple upgrades, breaking changes, deprecated gems)

## 📊 Vulnerability Summary

### Dependency Vulnerabilities (SCA)
- **80+ vulnerable RubyGems** from 2019
- Rails 5.2.3 with extensive CVE-laden components
- Nokogiri 1.10.3 with XXE and libxml2 vulnerabilities
- Expected **200+ total vulnerabilities** across direct and transitive dependencies
- Mix of critical, high, medium, and low severity issues

**Key Vulnerable Gems:**
- `rails: 5.2.3` (multiple CVEs across all components)
- `rack: 2.0.7` (path traversal, DoS, injection)
- `nokogiri: 1.10.3` (XXE, integer overflow, use-after-free)
- `loofah: 2.2.3` (XSS vulnerabilities)
- `json: 2.2.0` (unsafe object creation)
- `rubyzip: 1.2.3` (path traversal)
- `devise: 4.6.2` (auth bypass, session fixation)
- `carrierwave: 1.3.1` (RCE vulnerability)
- `paperclip: 6.1.0` (deprecated, file read vulnerability)
- `rest-client: 2.0.2` (session fixation, header injection)
- And 70+ more...

### Code Vulnerabilities (SAST)

**26 intentional code vulnerabilities** including:

1. **SQL Injection** (CWE-89) - app.rb:72
2. **Command Injection** (CWE-78) - app.rb:82
3. **Path Traversal** (CWE-22) - app.rb:93
4. **Unrestricted File Upload** (CWE-434) - app.rb:108
5. **Cross-Site Scripting** (CWE-79) - app.rb:122
6. **SSRF** (CWE-918) - app.rb:132
7. **RCE via eval()** (CWE-94) - app.rb:146
8. **Insecure Deserialization - Marshal.load** (CWE-502) - app.rb:157
9. **XXE Injection** (CWE-611) - app.rb:171-174
10. **YAML Deserialization** (CWE-502) - app.rb:188
11. **Mass Assignment** (CWE-915) - app.rb:206
12. **IDOR** (CWE-639) - app.rb:219
13. **Missing Authentication** (CWE-306) - app.rb:229
14. **Sensitive Data Exposure** (CWE-200) - app.rb:236-243
15. **Open Redirect** (CWE-601) - app.rb:251
16. **Weak Cryptography - MD5** (CWE-327) - app.rb:261
17. **Server-Side Template Injection** (CWE-1336) - app.rb:273-274
18. **Regular Expression DoS (ReDoS)** (CWE-1333) - app.rb:284
19. **LDAP Injection** (CWE-90) - app.rb:295
20. **Session Fixation** (CWE-384) - app.rb:306
21. **Hardcoded Credentials** (CWE-798) - app.rb:14-17
22. **Information Exposure via Errors** (CWE-209) - app.rb:331-333
23. **Missing Rate Limiting** (CWE-770) - app.rb:344
24. **Insecure Randomness** (CWE-330) - app.rb:356
25. **Directory Listing** (CWE-548) - app.rb:366
26. **Sensitive Data in GET Parameters** (CWE-598) - app.rb:376

Plus **90+ exposed secrets** in .env file

## 🚀 Setup

### Prerequisites
- Ruby 2.6.3+ (application uses Ruby 2.6.3)
- Bundler

### Installation

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/vulnerable-ruby-app.git
cd vulnerable-ruby-app

# Install dependencies (expect warnings about vulnerabilities)
bundle install

# Start the application
ruby app.rb
```

### Access the Application
Open your browser to `http://localhost:4567`

## 🔍 Testing Vulnerabilities

### Scan with Snyk
```bash
# Install Snyk CLI
npm install -g snyk

# Authenticate
snyk auth

# Test for vulnerabilities
snyk test

# Expected output: 200+ vulnerabilities
```

### Scan with Bundler Audit
```bash
gem install bundler-audit
bundle audit check --update
```

### Available Vulnerable Endpoints

The application exposes multiple intentionally vulnerable endpoints:

- `POST /api/login` - SQL Injection
- `GET /api/exec?cmd=ls` - Command Injection
- `GET /api/files?filename=test.txt` - Path Traversal
- `POST /api/upload` - Unrestricted File Upload
- `GET /api/search?query=test` - XSS
- `GET /api/proxy?url=http://example.com` - SSRF
- `POST /api/evaluate` - RCE via eval
- `POST /api/deserialize` - Insecure Deserialization (Marshal.load)
- `DELETE /api/admin/users/:id` - Missing Authentication
- `GET /api/users/:id` - IDOR
- `POST /api/parse-xml` - XXE Injection
- `POST /api/parse-yaml` - YAML Deserialization RCE
- `POST /api/register` - Mass Assignment
- `GET /api/debug` - Sensitive Data Exposure
- `GET /api/redirect?url=evil.com` - Open Redirect
- `POST /api/template` - Server-Side Template Injection
- `GET /api/regex?input=aaaaaa!` - ReDoS
- `POST /api/session-fixation` - Session Fixation
- And 8 more...

## 📚 Documentation

- **[VULNERABILITIES.md](VULNERABILITIES.md)** - Detailed vulnerability catalog with CVEs, CWEs, and remediation guidance
- **.env** - Exposed secrets and credentials (intentionally vulnerable)

## 🛡️ Remediation Scenarios

This application demonstrates various remediation complexities:

### Simple Direct Upgrades (30-40 vulnerabilities)
```bash
# Example: Update Nokogiri
bundle update nokogiri

# Update Rack
bundle update rack
```

### Framework Major Version Upgrade (100+ vulnerabilities)
```bash
# Rails 5.2 → 7.0 (Breaking changes)
# Update Gemfile:
gem 'rails', '~> 7.0'
bundle update rails
# Must update application code for API changes
```

### Deprecated Package Migration (10-20 vulnerabilities)
```ruby
# Paperclip is deprecated and unmaintained
# Must migrate to ActiveStorage (Rails built-in)
```

### Transitive Dependency Resolution (50+ vulnerabilities)
- Many vulnerabilities fixed by upgrading Rails
- Some require explicit version constraints in Gemfile
- Diamond dependency scenarios

## ⚠️ Security Notice

**DO NOT:**
- Deploy this application to production
- Expose this application to the internet
- Use any code patterns from this app in real applications
- Commit the .env file to version control (it's included here for educational purposes only)

**DO:**
- Use for security testing and tool validation
- Use for security training and education
- Run in isolated environments only
- Understand each vulnerability before testing

## 📖 Educational Use

This application is designed for:
- Testing SAST/SCA security scanners (Snyk, Brakeman, bundler-audit, etc.)
- Security training and workshops
- Understanding vulnerability remediation complexity
- Practicing secure coding techniques
- Testing CI/CD security pipelines

## 🧪 Testing Individual Vulnerabilities

### SQL Injection
```bash
curl -X POST http://localhost:4567/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin'\'' OR '\''1'\''='\''1'\''--", "password":"anything"}'
```

### Command Injection
```bash
curl "http://localhost:4567/api/exec?cmd=ls%20-la"
```

### XXE Injection
```bash
curl -X POST http://localhost:4567/api/parse-xml \
  -H "Content-Type: application/xml" \
  -d '<?xml version="1.0"?><!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><foo>&xxe;</foo>'
```

### YAML Deserialization RCE
```ruby
# Craft malicious YAML payload
payload = "--- !ruby/object:Gem::Installer\ni: x\n"
curl -X POST http://localhost:4567/api/parse-yaml -d "$payload"
```

## 🤝 Contributing

This is an intentionally vulnerable application. "Fixes" that remove vulnerabilities are not accepted, as the vulnerabilities are the features!

However, contributions welcome for:
- Additional vulnerability examples
- Documentation improvements
- Additional remediation scenario examples

## 📄 License

MIT License - Educational and testing purposes only.

## ⚡ Quick Start for Security Testing

```bash
# 1. Install dependencies
bundle install

# 2. Scan with Bundler Audit
bundle audit

# 3. Scan with Snyk
snyk test

# 4. Review vulnerabilities
cat VULNERABILITIES.md

# 5. Start the server
ruby app.rb

# 6. Test code vulnerabilities
curl http://localhost:4567/api/debug

# 7. Practice remediation
# Try fixing one vulnerability at a time and rescanning
```

---

**Remember**: This application is intentionally insecure. Use responsibly and only in controlled environments!
