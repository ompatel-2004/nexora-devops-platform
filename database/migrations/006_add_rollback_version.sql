-- Migration 006: Add Rollback Version to Deployment Audit

ALTER TABLE deployments
ADD COLUMN IF NOT EXISTS rollback_version VARCHAR(30);
