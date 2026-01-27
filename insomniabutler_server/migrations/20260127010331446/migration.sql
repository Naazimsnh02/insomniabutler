BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "journal_insights" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "insightType" text NOT NULL,
    "message" text NOT NULL,
    "confidence" double precision NOT NULL,
    "relatedEntryIds" text,
    "generatedAt" timestamp without time zone NOT NULL
);

--
-- ACTION ALTER TABLE
--
ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "sleepInsightsEnabled" boolean NOT NULL DEFAULT true;
ALTER TABLE "users" ALTER COLUMN "sleepInsightsEnabled" SET DEFAULT true;
UPDATE "users" SET "sleepInsightsEnabled" = true WHERE "sleepInsightsEnabled" IS NULL;

ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "sleepInsightsTime" text;

ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "journalInsightsEnabled" boolean NOT NULL DEFAULT true;
ALTER TABLE "users" ALTER COLUMN "journalInsightsEnabled" SET DEFAULT true;
UPDATE "users" SET "journalInsightsEnabled" = true WHERE "journalInsightsEnabled" IS NULL;

ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "journalInsightsTime" text;



--
-- MIGRATION VERSION FOR insomniabutler
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('insomniabutler', '20260127010331446', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260127010331446', "timestamp" = now();

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
