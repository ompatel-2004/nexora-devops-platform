# Nexora Systems — Multi-Environment Deployment Runbook

## Immutable Promotion Principle
Build an application version once, package it into an immutable archive (.zip or .jar), calculate its SHA-256 digest, publish it to Nexus, and promote that identical artifact across DEV, QA, STAGING, and PROD.
