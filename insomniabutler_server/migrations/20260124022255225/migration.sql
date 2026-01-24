BEGIN;

-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "chat_messages" ADD COLUMN "embedding" vector(768);
--
-- ACTION ALTER TABLE
--
ALTER TABLE "journal_entries" ADD COLUMN "embedding" vector(768);

-- Create HNSW indices for fast semantic search
CREATE INDEX IF NOT EXISTS journal_entries_embedding_idx 
ON journal_entries 
USING hnsw (embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);

CREATE INDEX IF NOT EXISTS chat_messages_embedding_idx 
ON chat_messages 
USING hnsw (embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);

--
-- MIGRATION VERSION FOR insomniabutler
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('insomniabutler', '20260124022255225', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260124022255225', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20251208110333922-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110333922-v3-0-0', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260109031533194', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260109031533194', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20251208110412389-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110412389-v3-0-0', "timestamp" = now();


COMMIT;
