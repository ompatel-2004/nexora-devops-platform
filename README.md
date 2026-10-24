# Nexora Systems — Enterprise Release Automation Platform

Comprehensive CI/CD, multi-environment artifact promotion, IIS infrastructure automation, zero-downtime release orchestration, and automated failure recovery platform.

## Architecture & Technology Stack
- Applications: inventory-api (.NET 8), inventory-web (Angular), reporting-service (Java/Spring Boot)
- Database: PostgreSQL 18 with 100 seeded SKUs and deployments audit log
- Infrastructure: Windows IIS (8 sites across DEV, QA, STAGING, PROD)
- Orchestration: Ansible (WSL2 control node via WinRM)
- CI/CD & Governance: Jenkins Declarative Pipeline, SonarQube Quality Gates, Nexus Repository 3
- Platform Tooling: devopsctl CLI

## Documentation
- Architecture Blueprint: docs/ARCHITECTURE.md
- Deployment Guide: docs/DEPLOYMENT.md
- Automated Rollback Specification: docs/ROLLBACK.md
- Disaster Recovery & Backup Plan: docs/DISASTER_RECOVERY.md
- Security & Secrets Policy: docs/SECURITY.md
- Troubleshooting Matrix: docs/TROUBLESHOOTING.md
- Engineering Decisions Log: docs/ENGINEERING_DECISIONS.md
- Future Architecture (Enterprise Scale): docs/FUTURE_ARCHITECTURE.md
- Final Comprehensive Report: FINAL_REPORT.md
