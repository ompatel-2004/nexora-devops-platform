# Nexora Systems — Security Policy & Operational Hardening

## 1. Secrets Management
- Zero Plaintext Credentials: Passwords and access tokens are strictly injected via runtime environment variables or Jenkins Credentials.
- Vault Integration: Production deployments utilize environment-based secret mapping rather than source-committed keys.

## 2. Remote Transport Hardening (WinRM)
- Encryption Mandatory: WinRM must operate with AllowUnencrypted = false.
- Authentication: Uses NTLM / Kerberos / Negotiate. Basic authentication over unencrypted HTTP is strictly forbidden.

## 3. Database Least Privilege Architecture
- The application user nexora_admin is restricted to non-superuser permissions:
  CREATE ROLE nexora_admin WITH LOGIN PASSWORD '<SECURE_PASSWORD>' NOSUPERUSER NOCREATEDB NOCREATEROLE;
  GRANT CONNECT ON DATABASE inventory_db TO nexora_admin;
  GRANT USAGE ON SCHEMA public TO nexora_admin;
  GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO nexora_admin;
  GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO nexora_admin;
