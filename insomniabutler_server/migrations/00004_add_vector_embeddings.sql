-- Enable pgvector extension for vector similarity search
CREATE EXTENSION IF NOT EXISTS vector;

-- Add embedding column to journal_entries
ALTER TABLE journal_entries 
ADD COLUMN IF NOT EXISTS embedding vector(768);

-- Add embedding column to chat_messages
ALTER TABLE chat_messages 
ADD COLUMN IF NOT EXISTS embedding vector(768);

-- Create HNSW index for fast similarity search on journal_entries
-- HNSW (Hierarchical Navigable Small World) is optimized for high-dimensional vectors
CREATE INDEX IF NOT EXISTS journal_entries_embedding_idx 
ON journal_entries 
USING hnsw (embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);

-- Create HNSW index for fast similarity search on chat_messages
CREATE INDEX IF NOT EXISTS chat_messages_embedding_idx 
ON chat_messages 
USING hnsw (embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);

-- Add comment for documentation
COMMENT ON COLUMN journal_entries.embedding IS 'Gemini gemini-embedding-1.0 vector (768 dimensions) for semantic search';
COMMENT ON COLUMN chat_messages.embedding IS 'Gemini gemini-embedding-1.0 vector (768 dimensions) for semantic search';
