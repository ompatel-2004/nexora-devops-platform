-- Migration 000: Deployment Metadata
CREATE TABLE IF NOT EXISTS deployment_metadata (
    id SERIAL PRIMARY KEY,
    deployment_id VARCHAR(100) NOT NULL,
    environment VARCHAR(50) NOT NULL,
    version VARCHAR(50) NOT NULL,
    artifact_sha256 VARCHAR(64),
    deployed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

