-- Migration 003: Add Inventory Status Column
ALTER TABLE products ADD COLUMN IF NOT EXISTS inventory_status VARCHAR(50) DEFAULT 'IN_STOCK';
