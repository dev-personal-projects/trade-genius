-- ═══════════════════════════════════════════════════════════════════════════
-- SUPABASE DATABASE SETUP FOR CHAT FEATURE
-- ═══════════════════════════════════════════════════════════════════════════
-- 
-- INSTRUCTIONS:
-- 1. Go to your Supabase project dashboard
-- 2. Click on "SQL Editor" in the left sidebar
-- 3. Click "New Query"
-- 4. Copy and paste this entire file
-- 5. Click "Run" to execute
-- 
-- WHAT THIS DOES:
-- - Creates chat_messages table to store all messages
-- - Creates indexes for fast queries
-- - Creates function to get conversation sessions
-- - Sets up Row Level Security (RLS) for data protection
-- ═══════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════════
-- STEP 1: Create chat_messages table
-- ═══════════════════════════════════════════════════════════════════════════
-- This table stores all chat messages between users and AI

CREATE TABLE IF NOT EXISTS chat_messages (
  -- Primary key: Unique identifier for each message
  id TEXT PRIMARY KEY,
  
  -- Session ID: Groups messages into conversations
  session_id TEXT NOT NULL,
  
  -- Role: Who sent the message ('user' or 'assistant')
  role TEXT NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
  
  -- Content: The actual message text
  content TEXT NOT NULL,
  
  -- Timestamp: When the message was sent
  timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- Metadata: Additional data (JSON format)
  -- Example: {"imageUrl": "/path/to/image.jpg"}
  metadata JSONB,
  
  -- User ID: Link to authenticated user (optional)
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE
);

-- ═══════════════════════════════════════════════════════════════════════════
-- STEP 2: Create indexes for fast queries
-- ═══════════════════════════════════════════════════════════════════════════
-- Indexes speed up database queries

-- Index on session_id: Fast lookup of all messages in a conversation
CREATE INDEX IF NOT EXISTS idx_chat_messages_session_id 
ON chat_messages(session_id);

-- Index on timestamp: Fast sorting by time
CREATE INDEX IF NOT EXISTS idx_chat_messages_timestamp 
ON chat_messages(timestamp DESC);

-- Index on user_id: Fast lookup of user's conversations
CREATE INDEX IF NOT EXISTS idx_chat_messages_user_id 
ON chat_messages(user_id);

-- ═══════════════════════════════════════════════════════════════════════════
-- STEP 3: Create function to get conversation sessions
-- ═══════════════════════════════════════════════════════════════════════════
-- This function returns a list of all conversations with summary info

CREATE OR REPLACE FUNCTION get_chat_sessions()
RETURNS TABLE (
  session_id TEXT,
  message_count BIGINT,
  first_message TEXT,
  last_timestamp TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    cm.session_id,
    COUNT(*) as message_count,
    -- Get first user message as preview
    (
      SELECT content 
      FROM chat_messages cm2
      WHERE cm2.session_id = cm.session_id 
        AND cm2.role = 'user' 
      ORDER BY cm2.timestamp ASC 
      LIMIT 1
    ) as first_message,
    MAX(cm.timestamp) as last_timestamp
  FROM chat_messages cm
  GROUP BY cm.session_id
  ORDER BY last_timestamp DESC;
END;
$$ LANGUAGE plpgsql;

-- ═══════════════════════════════════════════════════════════════════════════
-- STEP 4: Enable Row Level Security (RLS)
-- ═══════════════════════════════════════════════════════════════════════════
-- RLS ensures users can only access their own data

-- Enable RLS on the table
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Policy: Users can insert their own messages
CREATE POLICY "Users can insert own messages"
ON chat_messages
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can view their own messages
CREATE POLICY "Users can view own messages"
ON chat_messages
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Policy: Users can delete their own messages
CREATE POLICY "Users can delete own messages"
ON chat_messages
FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Policy: Allow anonymous users (for testing)
-- REMOVE THIS IN PRODUCTION!
CREATE POLICY "Allow anonymous access"
ON chat_messages
FOR ALL
TO anon
USING (true)
WITH CHECK (true);

-- ═══════════════════════════════════════════════════════════════════════════
-- STEP 5: Create sample data (optional - for testing)
-- ═══════════════════════════════════════════════════════════════════════════
-- Uncomment to insert test data

/*
INSERT INTO chat_messages (id, session_id, role, content, timestamp) VALUES
  ('1', 'session_001', 'user', 'What is Bitcoin?', NOW() - INTERVAL '1 hour'),
  ('2', 'session_001', 'assistant', 'Bitcoin is a decentralized digital currency...', NOW() - INTERVAL '59 minutes'),
  ('3', 'session_001', 'user', 'How does mining work?', NOW() - INTERVAL '58 minutes'),
  ('4', 'session_001', 'assistant', 'Mining is the process of validating transactions...', NOW() - INTERVAL '57 minutes');
*/

-- ═══════════════════════════════════════════════════════════════════════════
-- VERIFICATION QUERIES
-- ═══════════════════════════════════════════════════════════════════════════
-- Run these to verify setup is correct

-- Check if table exists
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_name = 'chat_messages'
);

-- Check if function exists
SELECT EXISTS (
  SELECT FROM pg_proc 
  WHERE proname = 'get_chat_sessions'
);

-- View all policies
SELECT * FROM pg_policies WHERE tablename = 'chat_messages';

-- ═══════════════════════════════════════════════════════════════════════════
-- USEFUL QUERIES FOR MANAGEMENT
-- ═══════════════════════════════════════════════════════════════════════════

-- View all messages
-- SELECT * FROM chat_messages ORDER BY timestamp DESC;

-- View all sessions
-- SELECT * FROM get_chat_sessions();

-- Count messages per session
-- SELECT session_id, COUNT(*) FROM chat_messages GROUP BY session_id;

-- Delete old messages (older than 30 days)
-- DELETE FROM chat_messages WHERE timestamp < NOW() - INTERVAL '30 days';

-- Delete specific session
-- DELETE FROM chat_messages WHERE session_id = 'session_id_here';

-- ═══════════════════════════════════════════════════════════════════════════
-- SETUP COMPLETE!
-- ═══════════════════════════════════════════════════════════════════════════
-- Your chat feature is now ready to use with Supabase database
