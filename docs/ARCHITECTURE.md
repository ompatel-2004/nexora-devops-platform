# Nexora Systems — Architecture Blueprint & Component Specifications

## 1. System Topology Overview
The Nexora Release Platform orchestrates three decoupled applications across 4 isolated deployment environments (DEV, QA, STAGING, PROD).

- Inventory API (.NET 8): Ports 8101 (DEV), 8102 (QA), 8103 (STAGING), 8104 (PROD)
- Inventory Web (Angular 17): Ports 8201 (DEV), 8202 (QA), 8203 (STAGING), 8204 (PROD)
- Reporting Service (Spring Boot 3): Port 8301
- Database Engine (PostgreSQL 18): Port 5432
