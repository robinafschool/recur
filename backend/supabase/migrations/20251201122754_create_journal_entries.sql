-- Create journal_entries table
-- Using gen_random_uuid() from pgcrypto extension (already enabled in Supabase)
CREATE TABLE IF NOT EXISTS journal_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  time TIME,
  preview TEXT,
  metadata JSONB DEFAULT '{}'::jsonb
);

-- Create index for user_id and date queries (most common query pattern)
CREATE INDEX IF NOT EXISTS idx_journal_entries_user_date 
  ON journal_entries(user_id, date DESC);

-- Create index for user_id and created_at queries
CREATE INDEX IF NOT EXISTS idx_journal_entries_user_created 
  ON journal_entries(user_id, created_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE journal_entries ENABLE ROW LEVEL SECURITY;

-- Create policy: Users can only see their own entries
CREATE POLICY "Users can view their own journal entries"
  ON journal_entries
  FOR SELECT
  USING (auth.uid() = user_id);

-- Create policy: Users can insert their own journal entries
CREATE POLICY "Users can insert their own journal entries"
  ON journal_entries
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Create policy: Users can update their own journal entries
CREATE POLICY "Users can update their own journal entries"
  ON journal_entries
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Create policy: Users can delete their own journal entries
CREATE POLICY "Users can delete their own journal entries"
  ON journal_entries
  FOR DELETE
  USING (auth.uid() = user_id);

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_journal_entries_updated_at
  BEFORE UPDATE ON journal_entries
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

