-- Add start_time and end_time for single schedule (window: e.g. 08:00–20:00)
-- Must run after create_reality_checks.
ALTER TABLE reality_checks
  ADD COLUMN IF NOT EXISTS start_time TEXT,
  ADD COLUMN IF NOT EXISTS end_time TEXT;

-- Drop existing constraints so we can allow type 'schedule'
ALTER TABLE reality_checks
  DROP CONSTRAINT IF EXISTS check_interval_type;

ALTER TABLE reality_checks
  DROP CONSTRAINT IF EXISTS reality_checks_type_check;

-- Allow type 'schedule' and validate schedule row shape
ALTER TABLE reality_checks
  ADD CONSTRAINT reality_checks_type_check CHECK (type IN ('interval', 'event', 'schedule'));

ALTER TABLE reality_checks
  ADD CONSTRAINT check_interval_type CHECK (
    (type = 'interval' AND interval_minutes IS NOT NULL AND event_description IS NULL) OR
    (type = 'event' AND event_description IS NOT NULL AND interval_minutes IS NULL) OR
    (type = 'schedule' AND interval_minutes IS NOT NULL AND start_time IS NOT NULL AND end_time IS NOT NULL AND event_description IS NULL)
  );
