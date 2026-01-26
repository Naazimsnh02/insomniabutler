BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "chat_messages" ADD COLUMN "widgetType" text;
ALTER TABLE "chat_messages" ADD COLUMN "widgetData" text;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "sleep_sessions" ADD COLUMN "sleepDataSource" text;
ALTER TABLE "sleep_sessions" ADD COLUMN "deviceType" text;
ALTER TABLE "sleep_sessions" ADD COLUMN "deviceModel" text;
ALTER TABLE "sleep_sessions" ADD COLUMN "recordingMethod" text;
ALTER TABLE "sleep_sessions" ADD COLUMN "timeInBedMinutes" bigint;
ALTER TABLE "sleep_sessions" ADD COLUMN "sleepEfficiency" double precision;
ALTER TABLE "sleep_sessions" ADD COLUMN "unspecifiedSleepDuration" bigint;
ALTER TABLE "sleep_sessions" ADD COLUMN "wristTemperature" double precision;

--
-- MIGRATION VERSION FOR insomniabutler
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('insomniabutler', '20260126125759680', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260126125759680', "timestamp" = now();

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
