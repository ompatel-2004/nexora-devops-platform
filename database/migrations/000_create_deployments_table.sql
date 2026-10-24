-- Migration 000: Create Deployments Audit Table
CREATE TABLE IF NOT EXISTS deployments (
    id SERIAL PRIMARY KEY,
    application VARCHAR(100) NOT NULL,
    version VARCHAR(50) NOT NULL,
    environment VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    deployed_by VARCHAR(100) DEFAULT 'system',
    rollback_version VARCHAR(50) NULL,
    deployed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
