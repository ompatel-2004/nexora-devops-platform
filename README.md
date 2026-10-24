Nexora Systems — Enterprise Release Automation Platform
An enterprise-grade, fully automated multi-environment release engineering platform engineered for Nexora Systems. This repository contains the complete implementation unifying source control governance, continuous integration, static code quality gates, artifact lifecycle management, infrastructure provisioning, immutable multi-environment deployments, automatic fault recovery/rollback, configuration-drift auditing, database migration/backup verification, and deployment observability across three heterogeneous application runtimes.
1. Executive Summary & Capabilities
The platform automates the end-to-end software delivery lifecycle, eliminating manual deployment errors through strict operational guarantees:
- Heterogeneous Runtimes: Automated builds, scans, and deployments for .NET 8 Web API, Angular 17 Single Page Application, and Java 17 / Spring Boot Reporting Service.
- Artifact Immutability (Build Once, Promote Everywhere): Release archives are compiled once, cryptographically signed with SHA-256 hashes, packaged alongside CycloneDX Software Bills of Materials (SBOMs), published to Nexus Repository Manager, and promoted across environments without rebuilding.
- Automated Failure Recovery & Rollback: Automatic detection of unhealthy deployments via HTTP status and connectivity probes, triggering an Ansible-driven rescue sequence that restores the previous known-good release and records rollback causality in PostgreSQL.
- Configuration & Secret Decoupling: Application binaries remain completely decoupled from environmental configuration; environment settings (appsettings.json, dynamic env.js, and Spring Boot arguments) are injected dynamically at deployment time.
- Infrastructure as Code & Drift Detection: Automated IIS site and application pool provisioning across 8 isolated hosting environments with automated drift detection comparing live runtime configurations against golden templates.
- Database Lifecycle Management: Automated sequential schema migrations (001–004), deterministic seeding (100 SKUs), atomic backups, and automated backup verification using ephemeral restore databases.
- Unified Developer Tooling (devopsctl): Standardized command-line interface managing builds, releases, environment promotions, fault simulations, drift audits, backups, and operational metrics.
2. System Architecture & Lab Topology
Developer Commit -> GitHub Repository (main, develop, release/1.4.2, hotfix/1.4.1-patch)
       |
       v
Jenkins Declarative Pipeline (:8080)
       |
       +--> SonarQube 9.9 LTS Quality Gate (:9000)
       |      |-- inventory-api       (.NET 8 Web API)
       |      |-- inventory-web       (Angular 17 SPA)
       |      \-- reporting-service   (Java 17 / Spring Boot)
       |
       +--> Nexus Repository Manager 3 (:8081)
       |      |-- nexora-releases     (Immutable semantic releases: 1.4.1, 1.4.2)
       |      \-- nexora-snapshots    (Development snapshots: 1.4.2-SNAPSHOT)
       |
       +--> Ansible Automation Engine (WSL2 Ubuntu Control Node via WinRM)
              |
              +--> Windows IIS Hosting Platform
              |      |-- DEV     (API: :8101, Web: :8201)
              |      |-- QA      (API: :8102, Web: :8202)
              |      |-- STAGING (API: :8103, Web: :8203)
              |      \-- PROD    (API: :8104, Web: :8204)
              |
              +--> Java Microservice Runtime
              |      \-- Reporting Service Daemon (:8301)
              |
              +--> PostgreSQL 18 Engine (:5432)
                     |-- Database: inventory_db (100 Seeded SKUs)
                     |-- Schema Tracking: schema_migrations
                     \-- Audit Trail: deployments table
3. Environment & Port Mapping Matrix
Environment	Component	Hosting Runtime	Port	Health / Verification URL
DEV	inventory-api	IIS Site: inventory-api-dev	8101	http://localhost:8101/health
DEV	inventory-web	IIS Site: inventory-web-dev	8201	http://localhost:8201/
QA	inventory-api	IIS Site: inventory-api-qa	8102	http://localhost:8102/health
QA	inventory-web	IIS Site: inventory-web-qa	8202	http://localhost:8202/
STAGING	inventory-api	IIS Site: inventory-api-staging	8103	http://localhost:8103/health
STAGING	inventory-web	IIS Site: inventory-web-staging	8203	http://localhost:8203/
PROD	inventory-api	IIS Site: inventory-api-prod	8104	http://localhost:8104/health
PROD	inventory-web	IIS Site: inventory-web-prod	8204	http://localhost:8204/
GLOBAL	reporting-service	Java 17 Background Service	8301	http://localhost:8301/health
CORE	Jenkins CI/CD	Windows Native Service	8080	http://localhost:8080/
CORE	SonarQube 9.9 LTS	Windows Native Service	9000	http://localhost:9000/
CORE	Nexus Repository 3	Windows Native Service	8081	http://localhost:8081/
CORE	PostgreSQL 18	WSL2 Local Daemon	5432	postgresql://localhost:5432/inventory_db


4. Repository Structure
nexora-devops-platform/
├── applications/
│   ├── inventory-api/            # .NET 8 Web API
│   │   ├── Controllers/
│   │   ├── Program.cs
│   │   └── appsettings.json
│   ├── inventory-web/            # Angular 17 SPA
│   │   ├── src/
│   │   └── angular.json
│   └── reporting-service/        # Java 17 Spring Boot Service
│       ├── src/
│       └── pom.xml
├── database/
│   ├── migrations/               # Sequential SQL schema migrations
│   │   ├── 001_initial_schema.sql
│   │   ├── 002_add_category.sql
│   │   ├── 003_add_inventory_status.sql
│   │   ├── 004_add_created_at.sql
│   │   └── run_migrations.sh     # Forward migration tracking engine
│   ├── seed/
│   │   └── 001_seed_products.sql # Deterministic seed (100 SKUs)
│   └── backup/                   # Automated database backups storage
├── devops/
│   ├── ansible/
│   │   ├── inventory.ini         # WinRM host inventory definitions
│   │   ├── playbooks/            # Provisioning & deployment playbooks
│   │   └── roles/                # Modular Ansible roles (iis_setup, deploy, rollback)
│   └── scripts/                  # Automation utilities
├── docs/                         # Comprehensive engineering documentation
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
│   └── Jenkinsfile               # Declarative multi-app release pipeline
├── cli/
│   └── devopsctl                 # Platform CLI management binary
├── FINAL_REPORT.md               # 15-section technical project audit report
└── README.md                     # Root evaluation and reproduction guide
5. Prerequisites
Before setting up the platform, ensure the following components are available on the Windows host and WSL2 environment:
Windows 11 Host Requirements
- Administrator access.
- Git for Windows (v2.40+).
- .NET 8 SDK and ASP.NET Core Hosting Bundle (Microsoft.DotNet.HostingBundle.8).
- Node.js (v18+ or v20+) and npm.
- Java Development Kit (JDK 17) and Apache Maven (v3.9+).
- Jenkins (running on port 8080).
- SonarQube 9.9 Community Edition (running on port 9000).
- Nexus Repository Manager 3 (running on port 8081).
WSL2 Linux Requirements (Ubuntu 22.04 LTS or later)
- Python 3.10+ with venv and pip.
- PostgreSQL 18 server and psql client utility.
- Standard utilities: curl, jq, zip, unzip, bc.
6. Complete Setup & Reproduction Guide
Execute the following steps sequentially to reproduce the entire environment from scratch.
Step 1: Windows Host Infrastructure Setup
Open an elevated PowerShell prompt (Run as Administrator):
1. Enable IIS and Required Windows Features:
   Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole, IIS-WebServer, IIS-CommonHttpFeatures, IIS-HttpErrors, IIS-ApplicationDevelopment, IIS-NetFxExtensibility45, IIS-ASPNET45 -All
2. Install .NET 8 Hosting Bundle & Restart Web Services:
   winget install Microsoft.DotNet.HostingBundle.8 --accept-source-agreements --accept-package-agreements
   net stop was /y
   net start w3svc
3. Configure WinRM for Ansible Automation:
   winrm quickconfig -q
   winrm set winrm/config/service/auth '@{Basic="true"}'
   winrm set winrm/config/service '@{AllowUnencrypted="true"}'
4. Verify Supporting Services:
   Ensure Jenkins (http://localhost:8080), SonarQube (http://localhost:9000), and Nexus (http://localhost:8081) services are running.
Step 2: WSL2 Linux Control Plane Setup
Open your Ubuntu WSL2 terminal:
1. Clone the Repository:
   git clone https://github.com/ompatel-2004/nexora-devops-platform.git
   cd nexora-devops-platform
2. Initialize Python Virtual Environment & Install Ansible:
   python3 -m venv ~/ansible-venv
   source ~/ansible-venv/bin/activate
   pip install --upgrade pip
   pip install ansible pywinrm psycopg2-binary
   ansible-galaxy collection install microsoft.iis community.windows community.general
3. Install and Configure PostgreSQL 18:
   sudo apt update && sudo apt install -y postgresql postgresql-contrib jq zip bc
   sudo service postgresql start
   
   # Initialize database credentials and database
   sudo -u postgres psql -c "CREATE USER nexora_admin WITH PASSWORD 'devops_secure_password_123' SUPERUSER;"
   sudo -u postgres psql -c "CREATE DATABASE inventory_db OWNER nexora_admin;"
4. Execute Sequential Schema Migrations (001–004):
   /mnt/c/nexora-devops-platform/database/migrations/run_migrations.sh
5. Seed Deterministic Sample Data (100 SKUs):
   psql -h localhost -U nexora_admin -d inventory_db -f database/seed/001_seed_products.sql
   
   # Verify that exactly 100 products exist
   psql -h localhost -U nexora_admin -d inventory_db -c "SELECT COUNT(*) FROM products;"
6. Provision 8 IIS Sites and Application Pools via Ansible:
   cd /mnt/c/nexora-devops-platform/devops/ansible
   ansible-playbook -i inventory.ini playbooks/setup_iis.yml
7. Install Platform CLI (devopsctl):
   sudo cp /mnt/c/nexora-devops-platform/cli/devopsctl /usr/local/bin/devopsctl
   sudo chmod +x /usr/local/bin/devopsctl
   devopsctl --help
7. Platform CLI (devopsctl) Reference
The /usr/local/bin/devopsctl utility serves as the unified interface for routine and automated lifecycle operations:
# 1. Build and package application
devopsctl build inventory-api 1.4.2

# 2. Publish immutable artifact to Nexus
devopsctl publish inventory-api 1.4.2

# 3. Deploy artifact to target environment
devopsctl deploy inventory-api 1.4.2 --env DEV
devopsctl deploy inventory-api 1.4.2 --env PROD

# 4. Verify deployment health endpoint
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
8. Mandatory Demonstration Scenarios
Scenario A: Successful Release & Promotion (Section 59)
Demonstrates promoting version 1.4.2 through the pipeline to Production:
1. Open Jenkins at http://localhost:8080/job/nexora-release-pipeline/.
2. Select Build with Parameters:
   - APPLICATION: inventory-api
   - VERSION: 1.4.2
   - TARGET_ENV: PROD
   - Click Build.
3. The pipeline checks out code, runs builds/tests, verifies the SonarQube quality gate, publishes immutable artifacts and SBOMs to Nexus, deploys to IIS, and runs post-deployment health probes.
4. Verify the production endpoint:curl -s http://localhost:8104/health | jq .
   Expected Response:{
     "status": "healthy",
     "version": "1.4.2",
     "database": "connected"
   }
Scenario B: Production Fault Injection & Automatic Rollback (Section 60)
Demonstrates automated rollback when an unhealthy release is deployed:
1. Execute a deployment of version 1.4.3 with simulated HTTP 500 failure:devopsctl deploy inventory-api 1.4.3 --env PROD --simulate-failure 500
2. Execution Sequence:
   - Version 1.4.3 binaries are deployed to inventory-api-prod.
   - Post-deployment health verification queries http://localhost:8104/health.
   - Health check fails with HTTP 500.
   - The Ansible rescue block triggers immediately.
   - The deployment engine queries the PostgreSQL deployments audit table for the last known SUCCESS version (1.4.2).
   - Version 1.4.2 binaries and configuration are restored.
   - IIS Application Pool is restarted and health verification passes.
   - A rollback record referencing rollback_of = '1.4.3' is recorded in PostgreSQL.
3. Confirm active production version returned to 1.4.2:curl -s http://localhost:8104/health | jq .
Scenario C: Configuration Drift Detection (Section 61)
Demonstrates runtime drift detection when server configurations are modified out-of-band:
1. Introduce configuration drift into the production site:sed -i 's/"Default": "Information"/"Default": "Debug"/' /mnt/c/inetpub/nexora/prod/api/appsettings.json
2. Execute the drift audit tool:devopsctl drift-check --env PROD
3. Detected Output:[DRIFT AUDIT] Scanning PROD environment configurations...
   [WARNING] CONFIGURATION DRIFT DETECTED IN PROD!
   File: C:\inetpub\nexora\prod\api\appsettings.json
     Key:       Logging.LogLevel.Default
     Expected:  Information
     Actual:    Debug
   Status: NON-COMPLIANT
Scenario D: Database Backup & Ephemeral Restore Verification (Section 62)
Demonstrates backup verification through restoration into an isolated database:
1. Execute the backup and verification command:devopsctl backup
   devopsctl verify-backup
2. Verification Mechanism:
   - Generates an atomic PostgreSQL SQL dump in database/backup/.
   - Provisions an isolated temporary database: inventory_verify_db.
   - Restores the full schema and data dump.
   - Executes validation queries confirming schema consistency and that all 100 product SKUs are present.
   - Automatically drops inventory_verify_db upon successful validation.
   - Outputs: [SUCCESS] Database backup verified successfully. 100/100 SKUs intact.
9. Git Branching Model & Release Governance (Section 11)
The platform adheres to GitFlow branching governance across four primary branch types:
feature/*  ----> develop ----> release/1.4.2 ----> main
                   ^                                 |
                   |                                 v
                   +--------------------------- hotfix/1.4.1-patch
- main: Production releases only. Every commit corresponds to an immutable production tag.
- develop: Integration branch for completed features.
- release/*: Release candidate stabilization branches (e.g., release/1.4.2).
- hotfix/*: Urgent production patches branched from main and merged back to both main and develop (e.g., hotfix/1.4.1-patch).
10. Security & Quality Gate Policies
- Zero Hard-Coded Credentials: Passwords, API tokens, and database credentials are excluded from Git repository tracking and are injected at runtime via deployment variables or encrypted configuration stores.
- Static Analysis Quality Gates: Enforced via SonarQube 9.9 LTS. Quality gate thresholds mandate:
  - Critical Bugs = 0
  - Vulnerabilities = 0
  - Security Hotspots Reviewed = 100%
- Cryptographic Checksums: Every packaged artifact produces a .sha256 signature stored in Nexus. The deployment engine recalculates and validates this checksum before extracting archives to target servers.
- Supply Chain Transparency (SBOM): Every CI build automatically outputs a CycloneDX JSON Software Bill of Materials (.sbom.json) tracking all runtime and compile-time dependencies.
11. Operational Troubleshooting Matrix
Problem	Root Cause	Diagnosis Step	Solution
Jenkins Build Fails (.NET)	Missing SDK / Hosting bundle	Review console output for dotnet command not found	Install .NET 8 SDK and ASP.NET Core Hosting Bundle
IIS Returns HTTP 500.19	Missing ASP.NET Core Module	Inspect Windows Application Event Log	Re-register the ASP.NET Core Module via Hosting Bundle
IIS Site Returns HTTP 503	Application Pool stopped	Run Get-WebAppPoolState -Name <pool> in PowerShell	Inspect event logs for startup crash; verify appsettings.json syntax
Health Check Connection Timeout	Port blocked by Windows Firewall	Run Test-NetConnection -Port <port>	Add inbound firewall rule allowing TCP traffic on target port
PostgreSQL Connection Refused	PostgreSQL daemon inactive	Execute sudo service postgresql status in WSL	Run sudo service postgresql start
SonarQube Analysis Fails	Incompatible scanner version or invalid token	Review scanner log for HTTP 401 or /api/v2 failures	Use dotnet-sonarscanner v6.2.0 with valid project token
Nexus Upload Fails (HTTP 401)	Invalid administrative credentials	Inspect Jenkins environment credentials block	Update NEXUS_USER and NEXUS_PASS in the pipeline configuration
Rollback Fails (Missing Backup)	Previous archive directory deleted	Check C:\nexora-devops-platform\artifacts\	Ensure artifact retention policy keeps at least the last 5 release archives
Drift Check Reports False Positives	Formatting differences in JSON	Review diff output in devopsctl drift-check	Ensure golden template formatting matches live deployment templates
WinRM Connection Refused	WinRM listener not configured	Run winrm enumerate winrm/config/listener	Execute winrm quickconfig -q in an Administrator PowerShell prompt


12. Technical Documentation Directory Index
Detailed technical specifications and design rationales are available in the repository:
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — Comprehensive infrastructure topology, sequence flows, and component responsibilities.
- [`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md) — Multi-environment deployment runbook and environment-promotion matrix.
- [`docs/ROLLBACK.md`](docs/ROLLBACK.md) — Automatic rescue mechanics, manual rollback procedures, and state restoration rules.
- [`docs/SECURITY.md`](docs/SECURITY.md) — Secret management policies, CycloneDX SBOM compliance, SonarQube quality gates, and SHA-256 integrity hashing.
- [`docs/DISASTER_RECOVERY.md`](docs/DISASTER_RECOVERY.md) — Backup schedules, automated verification mechanics, and RPO/RTO calculations.
- [`docs/PERFORMANCE.md`](docs/PERFORMANCE.md) — 10-run benchmark experiment (5 success / 5 rollback cycles) and bottleneck optimization analysis.
- [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) — Comprehensive 20-scenario operational troubleshooting matrix.
- [`docs/ENGINEERING_DECISIONS.md`](docs/ENGINEERING_DECISIONS.md) — Technical justifications for architectural questions Q1 through Q15.
- [`docs/FUTURE_ARCHITECTURE.md`](docs/FUTURE_ARCHITECTURE.md) — Enterprise scaling blueprint (500 developers, 20,000 deploys/month, Kubernetes, GitOps).
- [`FINAL_REPORT.md`](FINAL_REPORT.md) — 15-section technical audit answering all final project requirements.
