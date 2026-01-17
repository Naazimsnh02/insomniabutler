BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "chat_messages" (
    "id" bigserial PRIMARY KEY,
    "sessionId" text NOT NULL,
    "userId" bigint NOT NULL,
    "role" text NOT NULL,
    "content" text NOT NULL,
    "timestamp" timestamp without time zone NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "sleep_insights" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "insightType" text NOT NULL,
    "metric" text NOT NULL,
    "value" double precision NOT NULL,
    "description" text NOT NULL,
    "generatedAt" timestamp without time zone NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "sleep_sessions" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "bedTime" timestamp without time zone NOT NULL,
    "wakeTime" timestamp without time zone,
    "sleepLatencyMinutes" bigint,
    "usedButler" boolean NOT NULL,
    "thoughtsProcessed" bigint NOT NULL,
    "sleepQuality" bigint,
    "morningMood" text,
    "sessionDate" timestamp without time zone NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "thought_logs" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "sessionId" bigint,
    "category" text NOT NULL,
    "content" text NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    "resolved" boolean NOT NULL,
    "readinessIncrease" bigint NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "users" (
    "id" bigserial PRIMARY KEY,
    "email" text NOT NULL,
    "name" text NOT NULL,
    "sleepGoal" text,
    "bedtimePreference" timestamp without time zone,
    "createdAt" timestamp without time zone NOT NULL
);


--
-- MIGRATION VERSION FOR insomniabutler
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('insomniabutler', '20260117170635719', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260117170635719', "timestamp" = now();

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
