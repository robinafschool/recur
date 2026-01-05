-- Create reality_checks table
-- Using gen_random_uuid() from pgcrypto extension (already enabled in Supabase)
CREATE TABLE IF NOT EXISTS reality_checks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('interval', 'event')),
  interval_minutes INTEGER,
  event_description TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT check_interval_type CHECK (
    (type = 'interval' AND interval_minutes IS NOT NULL AND event_description IS NULL) OR
    (type = 'event' AND event_description IS NOT NULL AND interval_minutes IS NULL)
  )
);

-- Create index for user_id and active status queries
CREATE INDEX IF NOT EXISTS idx_reality_checks_user_active 
  ON reality_checks(user_id, is_active);

-- Create index for user_id queries
CREATE INDEX IF NOT EXISTS idx_reality_checks_user 
  ON reality_checks(user_id);

-- Enable Row Level Security (RLS)
ALTER TABLE reality_checks ENABLE ROW LEVEL SECURITY;

-- Create policy: Users can only see their own reality checks
CREATE POLICY "Users can view their own reality checks"
  ON reality_checks
  FOR SELECT
  USING (auth.uid() = user_id);

-- Create policy: Users can insert their own reality checks
CREATE POLICY "Users can insert their own reality checks"
  ON reality_checks
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Create policy: Users can update their own reality checks
CREATE POLICY "Users can update their own reality checks"
  ON reality_checks
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Create policy: Users can delete their own reality checks
CREATE POLICY "Users can delete their own reality checks"
  ON reality_checks
  FOR DELETE
  USING (auth.uid() = user_id);

-- Create trigger to automatically update updated_at timestamp
CREATE TRIGGER update_reality_checks_updated_at
  BEFORE UPDATE ON reality_checks
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

