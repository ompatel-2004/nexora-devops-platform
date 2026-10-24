Nexora Systems --- Enterprise Release Automation Platform
An enterprise release-engineering platform design for Nexora Systems.
The platform brings together source control, continuous integration,
static analysis, artifact management, infrastructure automation,
multi-environment deployments, health verification, rollback,
configuration-drift auditing, database backups, and operational
reporting across three application runtimes.
Implementation status: This README documents the intended
architecture, commands, and demonstration scenarios. Run the commands
and verify the referenced files, services, endpoints, and results in
your environment before treating any feature as implemented or tested.
Replace environment-specific values and credentials before use.

Table of contents
- Overview
- Applications and technology
  stack
- Architecture
- Environment and port matrix
- Repository layout
- Prerequisites
- Setup guide
- Database setup and seed data
- Build, publish, deploy, and
  verify
- Release promotion demonstration
- Rollback demonstration
- Configuration-drift
  demonstration
- Backup and restore verification
- Git branching and release
  governance
- Security guidance
- Troubleshooting
- Documentation index
Overview
The platform is designed to manage a release from source commit through
build, quality checks, artifact publication, deployment, and
post-deployment verification.

Core objectives:
- Build and validate the .NET 8 Inventory API, Angular Inventory Web
  application, and Java Reporting Service.
- Run static analysis and enforce the configured SonarQube quality
  gate.
- Store versioned build artifacts in Nexus Repository Manager.
- Promote the same immutable release artifact through DEV, QA,
  STAGING, and PROD.
- Automate IIS site configuration and deployment with Ansible.
- Verify application health after deployment and support rollback when
  verification fails.
- Maintain deployment audit history and support configuration-drift
  checks.
- Back up PostgreSQL and verify that backups can be restored.
- Provide a common devopsctl command-line interface for routine
  release operations.
Applications and technology stack
  Component               Technology              Purpose
  inventory-api         .NET 8 Web API          Inventory API and
                                                  health endpoint

  inventory-web         Angular 17 SPA          Inventory user
                                                  interface

  reporting-service     Java 17 / Spring Boot   Reporting service

  Database                PostgreSQL              Inventory data and
                                                  deployment audit
                                                  records

  CI/CD                   Jenkins Declarative     Build, test, scan,
                          Pipeline                publish, and deploy
                                                  orchestration

  Code quality            SonarQube 9.9 LTS       Static analysis and
                                                  quality-gate evaluation

  Artifact repository     Nexus Repository        Release and snapshot
                          Manager 3               artifact storage

  Configuration and       Ansible                 IIS provisioning and
  deployment                                      deployment automation

  Web hosting             Windows IIS             API and web application
                                                  hosting

  Automation control node WSL2 / Ubuntu           Ansible and operational
                                              scripts
Architecture
Developer
   |
   v
GitHub
  |-- feature/*
  |-- develop
  |-- release/*
  `-- main / hotfix/*
   |
   v
Jenkins Declarative Pipeline (:8080)
   |
   +--> Build and tests
   |
   +--> SonarQube quality gate (:9000)
   |
   +--> Nexus Repository Manager (:8081)
   |      |-- nexora-releases
   |      `-- nexora-snapshots
   |
   +--> Ansible control node (WSL2 / Ubuntu)
   |      |
   |      `--> Windows IIS
   |             |-- DEV API :8101 / Web :8201
   |             |-- QA API :8102 / Web :8202
   |             |-- STAGING API :8103 / Web :8203
   |             `-- PROD API :8104 / Web :8204
   |
   +--> Reporting Service (:8301)
   |
   `--> PostgreSQL (:5432)
          |-- inventory_db
          |-- schema migrations
          |-- product seed data
          `-- deployment audit history
Artifact promotion principle
Build an application version once, publish it to the artifact
repository, and deploy that same version to each subsequent environment.
Do not rebuild separately for QA, STAGING, and PROD. Store checksums and
release metadata where supported so that each deployment can be traced
to the artifact that was tested.
Environment and port matrix
The following ports are the intended local development mapping. Update
the table if your actual IIS bindings or service configuration differ.
  Environment   Application           Intended target                        Port Verification URL
  DEV           inventory-api       IIS site                               8101 http://localhost:8101/health
                                      inventory-api-dev                         

  DEV           inventory-web       IIS site                               8201 http://localhost:8201/
                                      inventory-web-dev                         

  QA            inventory-api       IIS site                               8102 http://localhost:8102/health
                                      inventory-api-qa                          

  QA            inventory-web       IIS site                               8202 http://localhost:8202/
                                      inventory-web-qa                          

  STAGING       inventory-api       IIS site                               8103 http://localhost:8103/health
                                      inventory-api-staging                     

  STAGING       inventory-web       IIS site                               8203 http://localhost:8203/
                                      inventory-web-staging                     

  PROD          inventory-api       IIS site                               8104 http://localhost:8104/health
                                      inventory-api-prod                        

  PROD          inventory-web       IIS site                               8204 http://localhost:8204/
                                      inventory-web-prod                        

  GLOBAL        reporting-service   Java service                           8301 http://localhost:8301/health

  CORE          Jenkins               CI/CD service                          8080 http://localhost:8080/

  CORE          SonarQube             Code quality service                   9000 http://localhost:9000/

  CORE          Nexus                 Artifact repository                    8081 http://localhost:8081/
  CORE          PostgreSQL            Database service                       5432 localhost:5432/inventory_db
Repository layout
The commands below assume a repository structure similar to this.
Confirm the actual paths in the checked-out repository and adjust
commands if the structure differs.
nexora-devops-platform/
├── inventory-api/
├── inventory-web/
├── reporting-service/
├── database/
│   ├── migrations/
│   └── seed/
├── devops/
│   ├── ansible/
│   └── scripts/
├── docs/
├── Jenkinsfile
├── README.md
└── FINAL_REPORT.md
Prerequisites
- Windows 11 host with administrator access for IIS configuration.
- WSL2 with Ubuntu 22.04 or later for Ansible and Linux automation
  scripts.
- Git.
- .NET 8 SDK and ASP.NET Core Hosting Bundle.
- Node.js and npm compatible with the Angular project.
- Java 17 and Maven or the build tool configured by the Reporting
  Service.
- PostgreSQL and the psql client.
- Jenkins, SonarQube, and Nexus Repository Manager, installed and
  configured.
- Python 3 and pip for the Ansible control environment.
- Network connectivity and appropriately scoped credentials for the
  target Windows host.
Check installed runtimes before starting:
dotnet --info
node --version
npm --version
java --version
git --version
In Ubuntu/WSL2:
python3 --version
psql --version
Setup guide
1. Clone the repository
Run in WSL2 Ubuntu:
git clone https://github.com/ompatel-2004/nexora-devops-platform.git
cd nexora-devops-platform
2. Enable IIS on Windows
Open PowerShell as Administrator. Enable only the IIS features required
by your applications and Windows version. Review the command and
available features on the target machine before applying it.
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole,IIS-WebServer,IIS-CommonHttpFeatures,IIS-HttpErrors -All
Install the ASP.NET Core Hosting Bundle for .NET 8 from Microsoft's
official .NET download page if it is not already installed. Then restart
IIS:
net stop was /y
net start w3svc
3. Prepare the Ansible control environment
Run in WSL2 Ubuntu:
sudo apt update
sudo apt install -y python3-venv python3-pip git jq zip
python3 -m venv ~/ansible-venv
source ~/ansible-venv/bin/activate
python -m pip install --upgrade pip
pip install ansible pywinrm psycopg2-binary
ansible-galaxy collection install microsoft.iis community.windows community.general
Configure the inventory and Ansible variables for your Windows host.
Store passwords and other secrets in Ansible Vault or an approved
secrets manager rather than in source control.
4. Verify the supporting services
Confirm that Jenkins, SonarQube, and Nexus are running and reachable:
- Jenkins: http://localhost:8080/
- SonarQube: http://localhost:9000/
- Nexus: http://localhost:8081/
Create or verify the configured Nexus repositories, SonarQube project,
Jenkins credentials, tool installations, and pipeline configuration
before running a release.
Database setup and seed data
The database name used by this design is inventory_db. The schema
migration and seed paths below are expected paths; check that the
scripts exist before running them.
1. Install and start PostgreSQL
For Ubuntu/WSL2, install PostgreSQL using the package version available
from your configured package source, or follow the official PostgreSQL
instructions if a specific major version is required.
sudo apt update
sudo apt install -y postgresql postgresql-contrib
sudo service postgresql start
Create a dedicated database role and database. Use a unique password
supplied securely; do not copy a sample password into a real
environment.
sudo -u postgres createuser --pwprompt nexora_admin
sudo -u postgres createdb --owner=nexora_admin inventory_db
Grant only the privileges the application needs. Avoid granting
superuser privileges to an application account.
2. Run migrations
From the repository root, inspect the migration runner and confirm its
prerequisites before executing it:
ls -la database/migrations
If the repository includes the migration runner at the expected path:
bash database/migrations/run_migrations.sh
3. Seed deterministic product data
If database/seed/001_seed_products.sql exists and is designed to be
safely repeatable, run:
psql -h localhost -U nexora_admin -d inventory_db -v ON_ERROR_STOP=1 \
  -f database/seed/001_seed_products.sql
Verify the result with a query against the actual product table and key
column names defined by your schema. For example, after adapting the
table name if necessary:
SELECT COUNT(*) FROM products;
The project requirement described in this README is at least 100
deterministic sample products (SKUs). Do not assume this requirement
is met until the query confirms the expected count. Re-running seed data
should not create duplicate products if the seed process is intended to
be repeatable.
Build, publish, deploy, and verify
The devopsctl examples below describe the intended CLI interface. They
will work only if the CLI has been implemented, installed, and
configured in the current environment.
CLI command reference
# Build an application version
devopsctl build inventory-api 1.4.2

# Publish the immutable artifact to Nexus
devopsctl publish inventory-api 1.4.2

# Deploy a specific version to an environment
devopsctl deploy inventory-api 1.4.2 --env PROD

# Check application health
devopsctl health inventory-api --env PROD

# Simulate a failed deployment and test rollback
devopsctl deploy inventory-api 1.4.3 --env PROD --simulate-failure 500

# Audit configuration drift
devopsctl drift-check --env PROD

# Create and verify a database backup
devopsctl backup
devopsctl verify-backup

# Review deployment history and metrics
devopsctl history
devopsctl metrics
Expected health response
The exact health payload depends on the implemented API. A response
might include status, deployed version, and database connectivity, for
example:
{
  "status": "healthy",
  "version": "1.4.2",
  "database": "connected"
}
Treat this JSON as an example of the expected response shape, not as
evidence that the endpoint has already returned it.
Release promotion demonstration
Use this scenario after the pipeline and deployment targets have been
configured.
1. Open the Jenkins pipeline configured for the Nexora release
   workflow.
2. Supply the release parameters expected by the Jenkinsfile, such as:
   - APPLICATION: inventory-api
   - VERSION: 1.4.2
   - TARGET_ENV: PROD
3. Ensure the build and tests pass and the SonarQube quality gate is
   green.
4. Confirm the artifact was published to Nexus and record its version
   and checksum if available.
5. Deploy the published artifact to the intended environment.
6. Verify the deployment through the configured health endpoint:
   http://localhost:8104/health
7. Record the pipeline run, artifact version, health-check result, and
   deployment audit event as evidence.
For a controlled promotion process, deploy and validate in DEV first,
then QA, then STAGING, and only then PROD. Apply the approval gates
required by the project or organization.
Rollback demonstration
Run failure-injection tests only in a disposable or explicitly approved
test environment. Do not intentionally break a production service.

Example command if supported by the implemented CLI:
devopsctl deploy inventory-api 1.4.3 --env QA --simulate-failure 500
Expected behavior for a correctly implemented rollback workflow:
1. The candidate deployment is attempted.
2. The health check fails or the configured failure is detected.
3. The pipeline marks the deployment as failed.
4. The previously known-good artifact and configuration are restored.
5. The service is checked again after rollback.
6. A deployment/rollback event is written to the audit history.
7. The final report records the failed version, restored version, and
   verification result.
Verify the actual state after the test; do not rely only on a successful
pipeline status.
Configuration-drift demonstration
Perform drift tests in a non-production environment or on a disposable
copy of the configuration.
1. Back up the test configuration file.
2. Change a harmless, expected value (for example, a log level) in the
   test environment.
3. Run the drift-check command if implemented:
   devopsctl drift-check --env QA
4. Confirm that the tool reports the target file, expected value, and
   actual value.
5. Restore the original configuration and run the check again.
An example warning could look like this:
[WARNING] CONFIGURATION DRIFT DETECTED IN QA
Target: <path-to-test-configuration>
Expected LogLevel: Information
Actual LogLevel:   Debug
The exact output depends on the implementation. Do not use a Linux sed
command against a Windows path unless that path is genuinely mounted and
accessible from the Linux environment.
Backup and restore verification
If implemented, the backup workflow should create a timestamped database
dump and verify that it can be restored to an isolated temporary
database. Never run a restore test against the live application
database.

Example CLI:
devopsctl backup
devopsctl verify-backup
A robust verification procedure should:
1. Create the backup and check the command's exit status.
2. Confirm that the backup file exists and is non-empty.
3. Restore it into a temporary database such as inventory_verify_db.
4. Validate the schema and representative data.
5. Check the product/SKU count against the project requirement (at
   least 100).
6. Capture the verification result.
7. Remove the temporary database only after verification completes and
   cleanup is safe.
Store backups in a protected location, restrict access, and periodically
test recovery. A backup is not verified merely because a dump file was
created.
Git branching and release governance
The intended branching model is based on GitFlow:
feature/* ---> develop ---> release/1.4.2 ---> main
                  ^                            |
                  |                            v
                  +---------------------- hotfix/1.4.1-patch
- main --- production-ready releases.
- develop --- integration branch for ongoing work.
- feature/* --- isolated feature development branched from and
  merged back into develop.
- release/* --- stabilization, regression testing, and release
  preparation.
- hotfix/* --- urgent fixes based on the production branch,
  merged back to the appropriate long-lived branches.
Use pull requests, review requirements, automated checks, version tags,
and release notes. Branch names in the diagram are illustrative; use the
branch and version names actually present in the repository.
Security guidance
- Do not commit secrets. Use Jenkins Credentials, Ansible Vault,
  or an approved secrets manager. Keep credentials out of README
  files, scripts, logs, and Git history.
- Do not enable unencrypted WinRM for routine use. Avoid
  AllowUnencrypted=true. Prefer WinRM over HTTPS with appropriate
  certificate validation and a least-privilege account. Enable only
  the authentication methods required by your environment.
- Use least privilege. Do not make the application database
  account a PostgreSQL superuser. Separate administration, deployment,
  and application credentials.
- Protect production deployments. Require approval and restrict
  who can deploy to PROD.
- Preserve artifact integrity. Record immutable versions and
  checksums, and verify artifacts before deployment.
- Keep configuration separate from artifacts. Store
  environment-specific configuration and secrets securely; do not bake
  production secrets into build artifacts.
- Scan and test releases. Enforce the required SonarQube quality
  gate and automated tests before promotion.
- Audit operational actions. Record deployment, rollback, backup,
  restore-verification, and configuration-drift events without logging
  secret values.
- Use secure transport and access controls. Restrict service ports
  to the required hosts and networks.
Troubleshooting
  Symptom                             Checks
  Jenkins is unavailable              Confirm the service is running,
                                      check its logs, and verify port
                                      8080 is not blocked or occupied.

  SonarQube quality gate fails        Review the analysis report,
                                      quality-gate conditions, test
                                      coverage configuration, and
                                      pipeline logs.

  Nexus publish fails                 Verify repository URL, credentials,
                                      permissions, version coordinates,
                                      and network connectivity.

  IIS returns HTTP 500                Check Windows Event Viewer, IIS
                                      logs, application logs, installed
                                      .NET Hosting Bundle, and
                                      application configuration.

  Health endpoint is unreachable      Confirm the IIS binding/port,
                                      application pool state, firewall
                                      rules, and health route.

  Ansible cannot connect to Windows   Check inventory variables, WinRM
                                      listener, firewall, authentication,
                                      TLS configuration, and credentials.

  PostgreSQL connection fails         Confirm the service is running,
                                      database and role exist, host/port
                                      are correct, and pg_hba.conf
                                      permits the intended connection.

  Product count is below 100          Inspect migration status,
                                      seed-script output, transaction
                                      failures, and the actual table
                                      being queried.

  Rollback does not restore service   Confirm the previous artifact and
                                      configuration were retained,
                                      rollback steps ran, and
                                      post-rollback health verification
                                      passed.

  Backup verification fails           Inspect the dump error, restore
                                      logs, database permissions,
                                      available disk space, and
                                  schema/data validation queries.
Documentation index
The following files are intended documentation targets. Keep only links
for files that actually exist in the repository.
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) --- Infrastructure
  topology, sequence flows, and component responsibilities.
- [`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md) --- Deployment runbook
  and environment-promotion matrix.
- [`docs/ROLLBACK.md`](docs/ROLLBACK.md) --- Automatic and manual
  rollback procedures.
- [`docs/SECURITY.md`](docs/SECURITY.md) --- Secret management,
  software-bill-of-materials practices, quality gates, and artifact
  integrity.
- [`docs/DISASTER_RECOVERY.md`](docs/DISASTER_RECOVERY.md) --- Backup
  schedule, restore verification, and recovery objectives.
- [`docs/PERFORMANCE.md`](docs/PERFORMANCE.md) --- Benchmark
  methodology, measured results, and bottleneck analysis.
- [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) --- Operational
  troubleshooting scenarios.
- [`docs/ENGINEERING_DECISIONS.md`](docs/ENGINEERING_DECISIONS.md) ---
  Architectural decision records and technical rationale.
- [`docs/FUTURE_ARCHITECTURE.md`](docs/FUTURE_ARCHITECTURE.md) ---
  Potential future scaling and platform evolution.
- [`FINAL_REPORT.md`](FINAL_REPORT.md) --- Final assessment, evidence,
  and requirement-by-requirement status.
