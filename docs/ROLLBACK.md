# Nexora Systems — Automated Rollback & Recovery Runbook

## Automatic Rollback Mechanism
When a deployment fails post-deployment health verification, the release manager queries the PostgreSQL deployments table for the previous successful version and restores the application state.
