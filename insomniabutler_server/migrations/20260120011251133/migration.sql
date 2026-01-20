BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "journal_entries" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "title" text,
    "content" text NOT NULL,
    "mood" text,
    "sleepSessionId" bigint,
    "tags" text,
    "isFavorite" boolean NOT NULL DEFAULT false,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "entryDate" timestamp without time zone NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "journal_prompts" (
    "id" bigserial PRIMARY KEY,
    "category" text NOT NULL,
    "promptText" text NOT NULL,
    "isActive" boolean NOT NULL DEFAULT true,
    "isSystemPrompt" boolean NOT NULL DEFAULT true,
    "createdAt" timestamp without time zone NOT NULL
);


--
-- MIGRATION VERSION FOR insomniabutler
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('insomniabutler', '20260120011251133', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260120011251133', "timestamp" = now();

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
