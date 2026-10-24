# Nexora Systems — Security Policy & Secrets Governance

## Secrets Policy
- Zero Plaintext Credentials in Source Control: Secrets, database passwords, and access tokens are injected via environment variables and Jenkins credentials.
- Static Analysis: Enforced via SonarQube 9.9 LTS.
- SBOM: CycloneDX 1.5 JSON generated for each build.
