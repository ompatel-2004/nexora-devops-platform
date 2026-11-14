-- Migration 005: Deployment Audit Trail
CREATE TABLE IF NOT EXISTS deployments (
    id SERIAL PRIMARY KEY,
    application VARCHAR(100) NOT NULL,
    version VARCHAR(50) NOT NULL,
    environment VARCHAR(50) NOT NULL,
    commit_sha VARCHAR(100),
    pipeline_id VARCHAR(100),
    status VARCHAR(50) NOT NULL,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE,
    deployed_by VARCHAR(50),
    rollback_of VARCHAR(100)
);

CREATE INDEX IF NOT EXISTS idx_deployments_application
    ON deployments(application);

CREATE INDEX IF NOT EXISTS idx_deployments_environment
    ON deployments(environment);

CREATE INDEX IF NOT EXISTS idx_deployments_status
    ON deployments(status);

CREATE INDEX IF NOT EXISTS idx_deployments_completed_at
    ON deployments(completed_at);
