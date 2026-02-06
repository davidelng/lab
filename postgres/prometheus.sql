-- Create a dedicated user for metrics
-- Grant only read access to lab database (replace default vars)
CREATE USER prometheus WITH PASSWORD 'prometheus';
GRANT CONNECT ON DATABASE homelab TO prometheus;
GRANT USAGE ON SCHEMA public TO prometheus;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO prometheus;

-- Automatically grant select on future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO prometheus;

