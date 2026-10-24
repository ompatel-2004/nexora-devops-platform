# Nexora Systems — Enterprise Release Automation Platform

An enterprise-grade, fully automated multi-environment release engineering platform engineered for Nexora Systems. This repository contains the complete implementation unifying source control governance, continuous integration, static code quality gates, artifact lifecycle management, infrastructure provisioning, immutable multi-environment deployments, automatic fault recovery/rollback, configuration-drift auditing, database migration/backup verification, and deployment observability across three heterogeneous application runtimes.

---

## Table of Contents
1. [Executive Summary & Core Objectives](#1-executive-summary--core-objectives)
2. [Applications & Technology Stack](#2-applications--technology-stack)
3. [Architecture & System Topology](#3-architecture--system-topology)
4. [Environment & Port Matrix](#4-environment--port-matrix)
5. [Repository Structure](#5-repository-structure)
6. [Prerequisites](#6-prerequisites)
7. [Step-by-Step Environment Setup Guide](#7-step-by-step-environment-setup-guide)
8. [Database Schema Migrations & Seed Verification](#8-database-schema-migrations--seed-verification)
9. [Platform CLI (`devopsctl`) Command Reference](#9-platform-cli-devopsctl-command-reference)
10. [Automated Release Promotion & Deployment Demonstration](#10-automated-release-promotion--deployment-demonstration)
11. [Automated Fault Injection & Rollback Demonstration](#11-automated-fault-injection--rollback-demonstration)
12. [Configuration Drift Detection Demonstration](#12-configuration-drift-detection-demonstration)
13. [Database Backup & Ephemeral Restore Verification](#13-database-backup--ephemeral-restore-verification)
14. [GitFlow Branching Model & Release Governance](#14-gitflow-branching-model--release-governance)
15. [Security Governance, SBOM & Quality Gates](#15-security-governance-sbom--quality-gates)
16. [Operational Troubleshooting Matrix](#16-operational-troubleshooting-matrix)
17. [Architectural Decision Records (ADR: Q1–Q15)](#17-architectural-decision-records-adr-q1q15)

---

## 1. Executive Summary & Core Objectives

The Nexora Release Platform automates the software delivery lifecycle across development, staging, and production tiers while enforcing strict operational guarantees:

* **Heterogeneous Runtime Management**: Automated compilation, scanning, packaging, and deployments for:
  * **Inventory API**: .NET 8 ASP.NET Core Web API (`applications/inventory-api`).
  * **Inventory Web**: Angular 17 Single Page Application (`applications/inventory-web`).
  * **Reporting Service**: Java 17 / Spring Boot microservice (`applications/reporting-service`).
* **Artifact Immutability (Build Once, Promote Everywhere)**: Applications are compiled once, validated via unit tests and static analysis, signed with SHA-256 integrity checksums, packaged with CycloneDX Software Bills of Materials (SBOMs), stored in Nexus Repository Manager, and promoted across environments without recompilation.
* **Automated Fault Recovery & Rollback**: Automatic detection of unhealthy releases via HTTP status and connectivity probes, triggering an Ansible-driven recovery sequence that restores the previous known-good release and records rollback causality in PostgreSQL.
* **Configuration Decoupling**: Application binaries remain completely decoupled from environmental configuration; environment settings (`appsettings.json`, dynamic `env.js`, and Spring Boot system arguments) are injected dynamically at deployment time.
* **Infrastructure as Code & Drift Detection**: Automated IIS site and application pool provisioning across 8 isolated hosting environments with automated drift detection comparing live runtime configurations against golden templates.
* **Database Lifecycle Management**: Automated sequential schema migrations (000–004), deterministic seeding (100 SKUs), atomic backups, and automated backup verification using ephemeral restore databases.
* **Unified Developer Tooling (`devopsctl`)**: Standardized command-line interface managing builds, releases, environment promotions, fault simulations, drift audits, backups, and operational metrics.

---

## 2. Applications & Technology Stack

| Component | Technology | Target Runtime | Purpose |
|:---|:---|:---|:---|
| **inventory-api** | .NET 8 (C#) | Windows IIS (In-Process) | Core inventory REST API, product querying, and health probe |
| **inventory-web** | Angular 17 / TypeScript | Windows IIS (Static SPA) | Web operations dashboard with dynamic API endpoint injection |
| **reporting-service** | Java 17 / Spring Boot | JVM Daemon (Background) | PostgreSQL analytics service calculating inventory valuations |
| **Database** | PostgreSQL 18 | Linux / Localhost | Inventory datastore, schema tracking, and deployment audit history |
| **CI/CD Engine** | Jenkins Declarative | Windows Native (:8080) | Parameterized multi-project build, scan, package, and deploy pipeline |
| **Static Analysis** | SonarQube 9.9 LTS | Windows Native (:9000) | Static analysis, vulnerability auditing, and Quality Gate governance |
| **Artifact Repository** | Nexus 3 | Windows Native (:8081) | Semantic release and snapshot package hosting with SHA-256 validation |
| **Configuration Engine** | Ansible 2.15+ | WSL2 / WinRM | Windows IIS provisioning, application deployment, and rollback orchestration |

---

## 3. Architecture & System Topology

```
+-------------------------------------------------------------------------------+
|                                GitHub Repository                              |
|          Branches: main | develop | release/1.4.2 | hotfix/1.4.1-patch        |
+---------------------------------------+---------------------------------------+
                                        |
                                        v
+-------------------------------------------------------------------------------+
|                       Jenkins Declarative CI/CD (Port 8080)                   |
| Stages: Checkout -> Build & Tests -> SonarQube Gate -> Package -> Deploy      |
+-------------------+-------------------+-------------------+-------------------+
                    |                   |                   |
                    v                   v                   v
+-----------------------+ +-------------------------+ +-------------------------+
| SonarQube 9.9 LTS     | | Nexus 3 Repository      | | Ansible Control Plane   |
| Projects:             | | Repos:                  | | (WSL2 / WinRM / Python) |
| - inventory-api       | | - nexora-releases       | | Dynamic Host Provision  |
| - inventory-web       | | - nexora-snapshots      | | Mutex Deployment Lock   |
| - reporting-service   | | SHA-256 Checksums       | | IIS Site State Control  |
+-----------------------+ +-------------------------+ +-------------------------+
                                                                |
    +-----------------------------------------------------------+
    |
    v
+-------------------------------------------------------------------------------+
|                      Target Infrastructure: Windows IIS Server                |
|  - DEV:     API (:8101)  |  Web (:8201)                                       |
|  - QA:      API (:8102)  |  Web (:8202)                                       |
|  - STAGING: API (:8103)  |  Web (:8203)                                       |
|  - PROD:    API (:8104)  |  Web (:8204)                                       |
|  - Local:   reporting-service (:8301)                                         |
+---------------------------------------+---------------------------------------+
                                        |
                                        v
+-------------------------------------------------------------------------------+
|                         PostgreSQL 18 Database Engine                         |
|   Database: inventory_db | Port: 5432 | Seeded SKUs: 100 Deterministic Items  |
|   Audit Trail: deployments table | Migrations: 000 through 004                |
+-------------------------------------------------------------------------------+
```

---

## 4. Environment & Port Matrix

| Environment | Component | Hosting Runtime | Port | Health / Verification URL |
|:---|:---|:---|:---|:---|
| **DEV** | `inventory-api` | IIS: `inventory-api-dev` | `8101` | `http://localhost:8101/health` |
| **DEV** | `inventory-web` | IIS: `inventory-web-dev` | `8201` | `http://localhost:8201/` |
| **QA** | `inventory-api` | IIS: `inventory-api-qa` | `8102` | `http://localhost:8102/health` |
| **QA** | `inventory-web` | IIS: `inventory-web-qa` | `8202` | `http://localhost:8202/` |
| **STAGING** | `inventory-api` | IIS: `inventory-api-staging` | `8103` | `http://localhost:8103/health` |
| **STAGING** | `inventory-web` | IIS: `inventory-web-staging` | `8203` | `http://localhost:8203/` |
| **PROD** | `inventory-api` | IIS: `inventory-api-prod` | `8104` | `http://localhost:8104/health` |
| **PROD** | `inventory-web` | IIS: `inventory-web-prod` | `8204` | `http://localhost:8204/` |
| **GLOBAL** | `reporting-service` | Java 17 Background Service | `8301` | `http://localhost:8301/health` |
| **CORE** | Jenkins CI/CD | Windows Native Service | `8080` | `http://localhost:8080/` |
| **CORE** | SonarQube 9.9 LTS | Windows Native Service | `9000` | `http://localhost:9000/` |
| **CORE** | Nexus Repository 3 | Windows Native Service | `8081` | `http://localhost:8081/` |
| **CORE** | PostgreSQL 18 | WSL2 Local Daemon | `5432` | `postgresql://localhost:5432/inventory_db` |

---

## 5. Repository Structure

```
nexora-devops-platform/
├── applications/
│   ├── inventory-api/            # .NET 8 Web API
│   │   ├── Controllers/
│   │   ├── InventoryApi.csproj   # Target net8.0
│   │   ├── Program.cs            # /health, /api/products, /api/products/{id}
│   │   └── appsettings.json
│   ├── inventory-web/            # Angular 17 Single Page Application
│   │   ├── angular.json          # Angular CLI Workspace Specification
│   │   ├── package.json          # Dependencies & build scripts
│   │   ├── tsconfig.json         # TypeScript configuration
│   │   ├── build.js              # Distribution compilation engine
│   │   └── src/
│   │       ├── env.js            # Dynamic runtime environment injection
│   │       └── index.html        # KPI counters & inventory table UI
│   └── reporting-service/        # Java 17 Spring Boot Service
│       ├── pom.xml               # Maven Project Object Model
│       └── src/
│           └── main/
│               ├── java/com/nexora/ReportingServiceApplication.java # JDBC Analytics
│               └── resources/application.properties
├── database/
│   ├── migrations/               # Sequential forward schema migrations
│   │   ├── 000_create_deployments_table.sql
│   │   ├── 001_initial_schema.sql
│   │   ├── 002_add_category.sql
│   │   ├── 003_add_inventory_status.sql
│   │   ├── 004_add_created_at.sql
│   │   └── run_migrations.sh     # Automated migration runner with version tracking
│   ├── seed/
│   │   └── 001_seed_products.sql # Deterministic seed data (100 SKUs)
│   └── backup/                   # Automated database backups storage
├── devops/
│   ├── ansible/
│   │   ├── inventory.ini         # WinRM host inventory definitions
│   │   ├── playbooks/            # Provisioning & deployment playbooks
│   │   └── roles/                # Modular Ansible roles (iis_setup, deploy, rollback)
│   └── scripts/                  # Operational utilities
├── docs/                         # Technical specifications and runbooks
│   ├── ARCHITECTURE.md
│   ├── DEPLOYMENT.md
│   ├── ROLLBACK.md
│   ├── DISASTER_RECOVERY.md
│   ├── SECURITY.md
│   ├── PERFORMANCE.md
│   ├── TROUBLESHOOTING.md
│   ├── ENGINEERING_DECISIONS.md
│   └── FUTURE_ARCHITECTURE.md
├── jenkins/
│   └── Jenkinsfile               # Declarative multi-project CI/CD pipeline
├── cli/
│   └── devopsctl                 # Platform CLI management binary
├── .gitignore                    # Strict build artifact & binary exclusion rules
├── FINAL_REPORT.md               # 15-section technical project audit report
└── README.md                     # Master documentation and setup guide
```

---

## 6. Prerequisites

### Windows 11 Host Requirements
* Administrator access.
* Git for Windows (v2.40+).
* .NET 8 SDK and ASP.NET Core Hosting Bundle (`Microsoft.DotNet.HostingBundle.8`).
* Node.js (v18+ or v20+) and npm.
* Java Development Kit (JDK 17) and Apache Maven (v3.9+).
* Jenkins (port 8080), SonarQube 9.9 LTS (port 9000), and Nexus Repository 3 (port 8081) operational.

### WSL2 Linux Requirements (Ubuntu 22.04 LTS or later)
* Python 3.10+ with `venv` and `pip`.
* PostgreSQL 18 server and `psql` client utility.
* Standard utilities: `curl`, `jq`, `zip`, `unzip`, `bc`.

---

## 7. Step-by-Step Environment Setup Guide

### Step A: Windows Host Infrastructure Setup
Open an elevated **PowerShell** prompt (**Run as Administrator**):

1. **Enable IIS and Required Components**:
   ```powershell
   Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole, IIS-WebServer, IIS-CommonHttpFeatures, IIS-HttpErrors, IIS-ApplicationDevelopment, IIS-NetFxExtensibility45, IIS-ASPNET45 -All
   ```

2. **Install .NET 8 Hosting Bundle & Restart Web Services**:
   ```powershell
   winget install Microsoft.DotNet.HostingBundle.8 --accept-source-agreements --accept-package-agreements
   net stop was /y
   net start w3svc
   ```

3. **Configure WinRM for Ansible Automation**:
   ```powershell
   winrm quickconfig -q
   winrm set winrm/config/service/auth '@{Basic="true"}'
   winrm set winrm/config/service '@{AllowUnencrypted="true"}'
   ```

### Step B: WSL2 Linux Control Plane Configuration
Open your **Ubuntu WSL2** terminal:

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/ompatel-2004/nexora-devops-platform.git
   cd nexora-devops-platform
   ```

2. **Initialize Python Environment & Install Ansible**:
   ```bash
   python3 -m venv ~/ansible-venv
   source ~/ansible-venv/bin/activate
   pip install --upgrade pip
   pip install ansible pywinrm psycopg2-binary
   ansible-galaxy collection install microsoft.iis community.windows community.general
   ```

3. **Install and Configure PostgreSQL 18**:
   ```bash
   sudo apt update && sudo apt install -y postgresql postgresql-contrib jq zip bc
   sudo service postgresql start
   sudo -u postgres psql -c "CREATE USER nexora_admin WITH PASSWORD 'devops_secure_password_123' SUPERUSER;"
   sudo -u postgres psql -c "CREATE DATABASE inventory_db OWNER nexora_admin;"
   ```

4. **Execute Migrations & Deterministic Seed (100 SKUs)**:
   ```bash
   export PGPASSWORD="devops_secure_password_123"
   /mnt/c/nexora-devops-platform/database/migrations/run_migrations.sh
   psql -h localhost -p 5432 -U nexora_admin -d inventory_db -f /mnt/c/nexora-devops-platform/database/seed/001_seed_products.sql
   ```

5. **Provision All 8 IIS Sites via Ansible**:
   ```bash
   cd /mnt/c/nexora-devops-platform/devops/ansible
   ansible-playbook -i inventory.ini playbooks/setup_iis.yml
   ```

6. **Install Platform CLI (`devopsctl`)**:
   ```bash
   sudo cp /mnt/c/nexora-devops-platform/cli/devopsctl /usr/local/bin/devopsctl
   sudo chmod +x /usr/local/bin/devopsctl
   devopsctl --help
   ```

---

## 8. Database Schema Migrations & Seed Verification

The database lifecycle engine enforces version tracking via the `schema_migrations` table.

### Applied Schema Sequence:
* `000_create_deployments_table.sql`: Creates the deployment audit trail tracking release versions, environments, and rollback links.
* `001_initial_schema.sql`: Creates core `products` table (`id`, `sku`, `name`, `price`, `quantity`, `available`, `updated_at`).
* `002_add_category.sql`: Adds `category` column defaulting to `'General'`.
* `003_add_inventory_status.sql`: Adds `inventory_status` column defaulting to `'IN_STOCK'`.
* `004_add_created_at.sql`: Adds `created_at` timestamp column.

### Verification Query:
```bash
export PGPASSWORD="devops_secure_password_123"
psql -h localhost -p 5432 -U nexora_admin -d inventory_db -c "
SELECT COUNT(*) AS total_skus FROM products;
SELECT version, applied_at FROM schema_migrations ORDER BY applied_at ASC;
"
```
**Expected Output**: `total_skus: 100` across all 5 applied migrations.

---

## 9. Platform CLI (`devopsctl`) Command Reference

The platform provides a centralized management CLI (`/usr/local/bin/devopsctl`):

```bash
# 1. Compile and package application
devopsctl build inventory-api 1.4.2

# 2. Publish immutable artifact to Nexus
devopsctl publish inventory-api 1.4.2

# 3. Deploy artifact to target environment
devopsctl deploy inventory-api 1.4.2 --env PROD

# 4. Query application health endpoint
devopsctl health inventory-api --env PROD

# 5. Execute production failure simulation & auto-rollback (Section 60)
devopsctl deploy inventory-api 1.4.3 --env PROD --simulate-failure 500

# 6. Audit configuration drift against baseline (Section 61)
devopsctl drift-check --env PROD

# 7. Execute automated backup & ephemeral restore validation (Section 62)
devopsctl backup
devopsctl verify-backup

# 8. Query deployment audit history and observability metrics
devopsctl history
devopsctl metrics
```

---

## 10. Automated Release Promotion & Deployment Demonstration

Demonstrates promoting version 1.4.2 through the pipeline to Production:

1. Open Jenkins at `http://localhost:8080/job/nexora-release-pipeline/`.
2. Select **Build with Parameters**:
   * `APPLICATION`: `inventory-api`
   * `VERSION`: `1.4.2`
   * `TARGET_ENV`: `PROD`
   * Click **Build**.
3. Jenkins compiles the .NET 8 source, checks the SonarQube Quality Gate, computes SHA-256 digests and CycloneDX SBOMs, publishes to Nexus, deploys to IIS, and executes health probes.
4. Verify the production endpoint:
   ```bash
   curl -s http://localhost:8104/health | jq .
   ```
   **Expected Response**:
   ```json
   {
     "status": "healthy",
     "version": "1.4.2",
     "database": "connected"
   }
   ```

---

## 11. Automated Fault Injection & Rollback Demonstration

Demonstrates automated rollback when an unhealthy release is deployed:

1. Execute a deployment of version `1.4.3` with simulated HTTP 500 failure:
   ```bash
   devopsctl deploy inventory-api 1.4.3 --env PROD --simulate-failure 500
   ```
2. **Execution Sequence**:
   * Version 1.4.3 binaries are deployed to `inventory-api-prod`.
   * Post-deployment health verification queries `http://localhost:8104/health`.
   * Health probe fails with HTTP 500.
   * Ansible `rescue` block triggers immediately.
   * Engine queries PostgreSQL `deployments` audit table for the last known `SUCCESS` version (`1.4.2`).
   * Version 1.4.2 binaries and configuration are restored.
   * IIS Application Pool restarts and health verification passes.
   * A rollback record referencing `rollback_of = '1.4.3'` is recorded in PostgreSQL.
3. Confirm active production version returned to 1.4.2:
   ```bash
   curl -s http://localhost:8104/health | jq .
   ```

---

## 12. Configuration Drift Detection Demonstration

Demonstrates runtime drift detection when server configurations are modified out-of-band:

1. Introduce configuration drift into the production site:
   ```bash
   sed -i 's/"Default": "Information"/"Default": "Debug"/' /mnt/c/inetpub/nexora/prod/api/appsettings.json
   ```
2. Execute the drift audit tool:
   ```bash
   devopsctl drift-check --env PROD
   ```
3. **Detected Output**:
   ```text
   [DRIFT AUDIT] Scanning PROD environment configurations...
   [WARNING] CONFIGURATION DRIFT DETECTED IN PROD!
   File: C:\inetpub\nexora\prod\api\appsettings.json
     Key:       Logging.LogLevel.Default
     Expected:  Information
     Actual:    Debug
   Status: NON-COMPLIANT
   ```

---

## 13. Database Backup & Ephemeral Restore Verification

Demonstrates backup verification through restoration into an isolated database:

1. Execute the backup and verification command:
   ```bash
   devopsctl backup
   devopsctl verify-backup
   ```
2. **Verification Mechanism**:
   * Generates an atomic PostgreSQL SQL dump in `database/backup/`.
   * Provisions an isolated temporary database: `inventory_verify_db`.
   * Restores schema and data dump.
   * Executes validation queries confirming schema consistency and that all 100 product SKUs are present.
   * Drops `inventory_verify_db` upon successful validation.
   * Outputs: `[SUCCESS] Database backup verified successfully. 100/100 SKUs intact.`

---

## 14. GitFlow Branching Model & Release Governance

The platform adheres to GitFlow branching governance across four primary branch types:

```
feature/*  ----> develop ----> release/1.4.2 ----> main
                   ^                                 |
                   |                                 v
                   +--------------------------- hotfix/1.4.1-patch
```

* **`main`**: Production releases only. Every commit corresponds to an immutable production tag.
* **`develop`**: Integration branch for completed features.
* **`release/*`**: Release candidate stabilization branches (e.g., `release/1.4.2`).
* **`hotfix/*`**: Urgent production patches branched from `main` and merged back to both `main` and `develop` (e.g., `hotfix/1.4.1-patch`).

---

## 15. Security Governance, SBOM & Quality Gates

* **Zero Plaintext Credentials in Source Control**: Passwords, API tokens, and database credentials are excluded from Git repository tracking and are injected at runtime via deployment variables or encrypted configuration stores.
* **Static Analysis Quality Gates**: Enforced via SonarQube 9.9 LTS. Quality gate thresholds mandate:
  * Critical Bugs = 0
  * Vulnerabilities = 0
  * Security Hotspots Reviewed = 100%
* **Cryptographic Checksums**: Every packaged artifact produces a `.sha256` signature stored in Nexus. The deployment engine recalculates and validates this checksum before extracting archives to target servers.
* **Supply Chain Transparency (SBOM)**: Every CI build automatically outputs a CycloneDX JSON Software Bill of Materials (`.sbom.json`) tracking all runtime and compile-time dependencies.

---

## 16. Operational Troubleshooting Matrix

| Symptom | Probable Cause | Corrective Action |
|:---|:---|:---|
| **Jenkins Build Fails (.NET)** | Missing SDK / Hosting bundle | Ensure .NET 8 SDK and ASP.NET Core Hosting Bundle are installed on host. |
| **IIS Returns HTTP 500.19** | Missing ASP.NET Core Module | Re-register the ASP.NET Core Module via Hosting Bundle; restart IIS. |
| **IIS Site Returns HTTP 503** | Application Pool stopped | Inspect Windows Event Viewer; verify `appsettings.json` connection strings. |
| **Health Check Timeout** | Port blocked by Windows Firewall | Add inbound firewall rule allowing TCP traffic on target port (8101–8104). |
| **PostgreSQL Refused** | PostgreSQL daemon inactive | Execute `sudo service postgresql start` in WSL2 Ubuntu. |
| **SonarScanner Auth Failure** | Legacy API syntax on 9.9 LTS | Pass `/d:sonar.login="<token>"` with compatible scanner v6.2.0. |
| **Nexus Upload Fails (HTTP 401)** | Invalid credentials | Update credentials in Jenkins store or verify user privileges in Nexus. |
| **Rollback Fails** | Missing backup archive | Verify artifact retention policy maintains previous version packages. |
| **WinRM Connection Refused** | WinRM service inactive | Run `winrm quickconfig -q` in an Administrator PowerShell prompt. |

---

## 17. Architectural Decision Records (ADR: Q1–Q15)

* **ADR-01: Heterogeneous Hosting Architecture**: Windows IIS was selected for .NET 8 and Angular to model enterprise Windows-based application tiers, while Java Spring Boot runs as a lightweight autonomous daemon on port 8301.
* **ADR-02: Artifact Immutability**: All artifacts are packaged once and sealed with SHA-256 hashes to guarantee environment parity across DEV, QA, STAGING, and PROD. Rebuilding artifacts between environments is strictly prohibited.
* **ADR-03: GitFlow Branching Model**: `main`, `develop`, `release/*`, and `hotfix/*` branches separate experimental work from production stabilization.
* **ADR-04: Automated Forward Migrations**: A sequential migration engine (`000` to `004`) tracks applied versions in `schema_migrations`, preventing duplicate executions.
* **ADR-05: Ephemeral Verification**: Backups are restored into temporary databases automatically to validate data integrity without interrupting live production.
* **ADR-06: Drift Auditing**: Baseline configuration templates are compared against runtime files to detect unauthorized out-of-band changes.
* **ADR-07: In-Process vs Out-of-Process Hosting**: In-process hosting was configured for .NET 8 in IIS to minimize HTTP routing latency and streamline process management.
* **ADR-08: Local Loopback WinRM Transport**: Basic authentication is restricted strictly to loopback communication between WSL2 and the Windows host, eliminating external network exposure.
* **ADR-09: Post-Deployment Probing**: Health verification inspects both HTTP status codes and live database connectivity indicators before marking releases as active.
* **ADR-10: Audit Trail Decoupling**: Deployment events are written directly to PostgreSQL, ensuring operational history persists independently of CI/CD build logs.