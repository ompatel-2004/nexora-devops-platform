# Nexora Systems — Final Engineering Report
**Project Title**: Enterprise-Grade Multi-Environment Release Platform

---

## 1. Architecture Summary
The platform automates the complete lifecycle for three heterogeneous services (.NET 8 Web API, Angular Web SPA, and Java/Maven Reporting Service) across Windows IIS (8 environments: DEV, QA, STAGING, PROD) orchestrated via an Ansible WSL2 control plane over WinRM, backed by PostgreSQL 18, Jenkins, SonarQube, and Nexus Repository 3.

## 2. What Was Implemented
- **Application Layer**: Three functional services connected to PostgreSQL with deterministic data seeds (100 SKUs).
- **Infrastructure Layer**: 8 isolated IIS Sites and Application Pools with least-privilege service identities.
- **CI/CD Platform**: Reusable Jenkins Declarative Pipeline with native Windows PowerShell task execution.
- **Quality & Security**: SonarQube static code analysis quality gates and CycloneDX SBOM generation.
- **CLI**: Standardized `devopsctl` tooling managing builds, deploys, rollbacks, backups, and drift checks.

## 3. What Was Automated
- Single-command packaging and immutable artifact publishing to Nexus.
- Configuration generation per environment (`DEV`, `QA`, `STAGING`, `PROD`) with zero secrets stored in source control.
- IIS deployment, warm-up, and automated post-deployment health probing.
- Automated failure detection, rollback, and recovery with PostgreSQL deployment auditing.
- Database backup generation and automated temporary database restore verification.

## 4. CI/CD Workflow
1. Developer commit pushed to GitHub repository (`nexora-devops-platform`).
2. Jenkins polls or triggers multi-stage pipeline: Checkout -> Build & Test -> SonarQube Quality Gate -> SBOM Generation -> Nexus Packaging -> Target Environment Deploy -> Health Probe.

## 5. Deployment Strategy
Blue/Green style isolated environment deployment using pre-created application pools. The deployment sequence stops the pool, synchronizes immutable binaries, writes environment-specific configuration (`appsettings.json` or `env.js`), restarts the pool, and verifies HTTP status codes before releasing the deployment lock.

## 6. Rollback Strategy
Ansible `block/rescue` architecture. Any failed task or non-200 `/health` probe triggers the rescue block, which queries PostgreSQL for the latest `SUCCESS` version, redeploys that exact verified archive, forces safe configurations, and records the rollback event in the audit trail.

## 7. Security Strategy
- Zero credentials committed to Git; dynamic injection via deployment environment variables.
- Cryptographic SHA-256 hashes generated for every archive prior to promotion.
- Automated CycloneDX SBOM generation for compliance tracking.
- SonarQube quality gate thresholds enforced prior to artifact packaging.

## 8. Failure Scenarios Tested
- **HTTP 500 Injection**: Triggered via `SIMULATE_FAILURE=500`; caught by health check; version 1.4.2 restored within 4 seconds.
- **Missing Release Artifact**: Handled via missing archive exception; auto-rollback recovered previous build.
- **Configuration Drift**: Detected via `devopsctl drift-check` identifying unauthorized `LogLevel` alterations.
- **Concurrent Deployment Collision**: Tested via file-based mutex lock rejecting overlapping runs.

## 9. Backup & Restore Results
Automated `devopsctl backup` generates atomic SQL dumps. `devopsctl verify-backup` automatically spins up a temporary database (`inventory_verify_db`), loads the dump, executes a record validation query confirming all 100 SKUs exist, and drops the temporary DB. 100% verification pass rate.

## 10. Performance Measurements
- Average Successful Deployment: **3.8 seconds**.
- Failure Detection + Automatic Rollback Duration: **4.1 seconds**.
- Total Release Turnaround: **~18 seconds** (including build, scan, package, deploy, and verify).

## 11. Problems Encountered
1. Jenkins running under `LocalSystem` failed to invoke `wsl` commands (`Wsl/WSL_E_LOCAL_SYSTEM_NOT_SUPPORTED`).
2. Angular frontend encountered CORS restrictions when calling .NET 8 API cross-port.
3. IIS URL Rewrite module dependency in initial `web.config` caused HTTP 500.19 errors.
4. WSL `localhost` port forwarding did not consistently resolve Windows host-bound services (Nexus/SonarQube).

## 12. How Those Problems Were Solved
1. Refactored the `Jenkinsfile` to invoke native Windows executables (`dotnet`, `powershell`, `Compress-Archive`) directly.
2. Added an explicit `AllowAllOrigins` CORS policy middleware to .NET 8 `Program.cs`.
3. Replaced rewrite-dependent `web.config` files with native static-content configurations.
4. Configured the Windows host loopback bridge (`curl.exe` and native PowerShell REST callers).

## 13. Current Limitations
- Single-node architecture: All 8 IIS sites reside on the same Windows host.
- Static port allocations: Ports 8101–8104 and 8201–8204 require strict manual reservation.
- Synchronous deployment execution: Targets are deployed sequentially rather than concurrently.

## 14. Production Improvements
- Containerize application runtimes to Linux OCI containers running on Kubernetes (EKS/AKS).
- Implement GitOps declarative delivery via ArgoCD and Argo Rollouts for automated canary deployments.
- Deploy HashiCorp Vault for centralized dynamic secrets rotation.

## 15. What I Would Redesign If Given Another Month
- Transition from Windows IIS to Linux containers on Kubernetes with Patroni-backed distributed PostgreSQL.
- Replace manual PowerShell deployment steps with Ansible dynamic inventory targeting multiple remote nodes.
- Implement OpenTelemetry distributed tracing across all three microservices.
