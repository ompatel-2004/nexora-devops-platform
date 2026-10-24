-- Migration 000: Create Deployments Audit Table with Complete Operational Metadata
CREATE TABLE IF NOT EXISTS deployments (
    id SERIAL PRIMARY KEY,
    application VARCHAR(100) NOT NULL,
    version VARCHAR(50) NOT NULL,
    environment VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    commit_sha VARCHAR(100) DEFAULT 'HEAD',
    pipeline_id VARCHAR(100) DEFAULT 'manual',
    deployed_by VARCHAR(100) DEFAULT 'system',
    rollback_version VARCHAR(50) NULL,
    rollback_of VARCHAR(50) NULL,
    deployed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_deployments_app_env ON deployments (application, environment, status);
