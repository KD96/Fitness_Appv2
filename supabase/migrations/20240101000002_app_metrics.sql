-- Migration: Add app_metrics table for MetricKit data
-- Created: 2024-01-01 00:00:02

-- Create app_metrics table
CREATE TABLE IF NOT EXISTS app_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    type TEXT NOT NULL CHECK (type IN ('performance', 'crash', 'hang', 'custom')),
    timestamp TIMESTAMPTZ NOT NULL,
    data JSONB NOT NULL DEFAULT '{}',
    device_info JSONB NOT NULL DEFAULT '{}',
    app_version TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_app_metrics_user_id ON app_metrics(user_id);
CREATE INDEX IF NOT EXISTS idx_app_metrics_type ON app_metrics(type);
CREATE INDEX IF NOT EXISTS idx_app_metrics_timestamp ON app_metrics(timestamp);
CREATE INDEX IF NOT EXISTS idx_app_metrics_created_at ON app_metrics(created_at);
CREATE INDEX IF NOT EXISTS idx_app_metrics_app_version ON app_metrics(app_version);

-- Create composite indexes for common queries
CREATE INDEX IF NOT EXISTS idx_app_metrics_user_type_timestamp ON app_metrics(user_id, type, timestamp);
CREATE INDEX IF NOT EXISTS idx_app_metrics_type_timestamp ON app_metrics(type, timestamp);

-- Create GIN index for JSONB data fields
CREATE INDEX IF NOT EXISTS idx_app_metrics_data_gin ON app_metrics USING GIN(data);
CREATE INDEX IF NOT EXISTS idx_app_metrics_device_info_gin ON app_metrics USING GIN(device_info);

-- Add trigger for updated_at
CREATE OR REPLACE FUNCTION update_app_metrics_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_app_metrics_updated_at
    BEFORE UPDATE ON app_metrics
    FOR EACH ROW
    EXECUTE FUNCTION update_app_metrics_updated_at();

-- Enable Row Level Security
ALTER TABLE app_metrics ENABLE ROW LEVEL SECURITY;

-- RLS Policies for app_metrics

-- Users can insert their own metrics (or anonymous metrics)
CREATE POLICY "Users can insert their own metrics" ON app_metrics
    FOR INSERT
    WITH CHECK (
        user_id IS NULL OR 
        user_id = auth.uid()
    );

-- Users can view their own metrics
CREATE POLICY "Users can view their own metrics" ON app_metrics
    FOR SELECT
    USING (
        user_id IS NULL OR 
        user_id = auth.uid()
    );

-- Service role can access all metrics (for analytics)
CREATE POLICY "Service role can access all metrics" ON app_metrics
    FOR ALL
    USING (auth.jwt() ->> 'role' = 'service_role');

-- Anonymous metrics policy (for crash reports without user context)
CREATE POLICY "Allow anonymous metrics" ON app_metrics
    FOR INSERT
    WITH CHECK (user_id IS NULL);

-- Create a view for crash reports summary
CREATE OR REPLACE VIEW crash_reports_summary AS
SELECT 
    DATE_TRUNC('day', timestamp) as crash_date,
    app_version,
    device_info->>'model' as device_model,
    device_info->>'system_version' as system_version,
    data->>'crash_signal' as crash_signal,
    data->>'crash_exception_type' as exception_type,
    COUNT(*) as crash_count
FROM app_metrics 
WHERE type = 'crash'
GROUP BY 
    DATE_TRUNC('day', timestamp),
    app_version,
    device_info->>'model',
    device_info->>'system_version',
    data->>'crash_signal',
    data->>'crash_exception_type'
ORDER BY crash_date DESC, crash_count DESC;

-- Create a view for performance metrics summary
CREATE OR REPLACE VIEW performance_metrics_summary AS
SELECT 
    DATE_TRUNC('hour', timestamp) as metric_hour,
    app_version,
    device_info->>'model' as device_model,
    AVG((data->>'launch_time')::NUMERIC) as avg_launch_time,
    AVG((data->>'cpu_time')::NUMERIC) as avg_cpu_time,
    AVG((data->>'peak_memory')::NUMERIC) as avg_peak_memory,
    COUNT(*) as metric_count
FROM app_metrics 
WHERE type = 'performance'
    AND data->>'launch_time' IS NOT NULL
GROUP BY 
    DATE_TRUNC('hour', timestamp),
    app_version,
    device_info->>'model'
ORDER BY metric_hour DESC;

-- Create function to clean old metrics (retention policy)
CREATE OR REPLACE FUNCTION cleanup_old_metrics(retention_days INTEGER DEFAULT 90)
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM app_metrics 
    WHERE created_at < NOW() - INTERVAL '1 day' * retention_days;
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to get metrics stats
CREATE OR REPLACE FUNCTION get_metrics_stats(
    start_date TIMESTAMPTZ DEFAULT NOW() - INTERVAL '7 days',
    end_date TIMESTAMPTZ DEFAULT NOW()
)
RETURNS TABLE (
    metric_type TEXT,
    total_count BIGINT,
    unique_users BIGINT,
    unique_devices BIGINT,
    app_versions TEXT[]
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m.type as metric_type,
        COUNT(*) as total_count,
        COUNT(DISTINCT m.user_id) as unique_users,
        COUNT(DISTINCT m.device_info->>'identifier_for_vendor') as unique_devices,
        ARRAY_AGG(DISTINCT m.app_version) as app_versions
    FROM app_metrics m
    WHERE m.timestamp BETWEEN start_date AND end_date
    GROUP BY m.type
    ORDER BY total_count DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions
GRANT SELECT ON crash_reports_summary TO authenticated;
GRANT SELECT ON performance_metrics_summary TO authenticated;
GRANT EXECUTE ON FUNCTION get_metrics_stats TO authenticated;
GRANT EXECUTE ON FUNCTION cleanup_old_metrics TO service_role;

-- Insert sample data for testing
INSERT INTO app_metrics (user_id, type, timestamp, data, device_info, app_version) VALUES
(
    NULL, -- Anonymous crash report
    'crash',
    NOW() - INTERVAL '1 hour',
    '{
        "crash_signal": 11,
        "crash_exception_type": 1,
        "crash_exception_code": 0,
        "crash_termination_reason": "Segmentation fault",
        "stack_trace": [
            {
                "binary_name": "Fitness_Appv2",
                "address": "0x100001000",
                "symbol": "main"
            }
        ]
    }'::jsonb,
    '{
        "model": "iPhone",
        "system_name": "iOS",
        "system_version": "17.0",
        "identifier_for_vendor": "test-device-1"
    }'::jsonb,
    '1.0.0 (1)'
),
(
    (SELECT id FROM auth.users LIMIT 1), -- First user's performance metrics
    'performance',
    NOW() - INTERVAL '30 minutes',
    '{
        "launch_time": 1.5,
        "resume_time": 0.8,
        "cpu_time": 120.5,
        "peak_memory": 50000000,
        "cellular_upload": 500000,
        "wifi_download": 2000000
    }'::jsonb,
    '{
        "model": "iPhone",
        "system_name": "iOS",
        "system_version": "17.0",
        "identifier_for_vendor": "test-device-2"
    }'::jsonb,
    '1.0.0 (1)'
);

-- Add comment
COMMENT ON TABLE app_metrics IS 'Stores app performance metrics and crash logs from MetricKit';
COMMENT ON COLUMN app_metrics.type IS 'Type of metric: performance, crash, hang, or custom';
COMMENT ON COLUMN app_metrics.data IS 'Metric-specific data in JSON format';
COMMENT ON COLUMN app_metrics.device_info IS 'Device information including model, OS version, etc.';
COMMENT ON VIEW crash_reports_summary IS 'Aggregated view of crash reports for analytics';
COMMENT ON VIEW performance_metrics_summary IS 'Aggregated view of performance metrics for monitoring'; 