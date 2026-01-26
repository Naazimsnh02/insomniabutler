BEGIN;

--
-- ACTION ALTER TABLE
--
CREATE INDEX "idx_sleep_sessions_data_source" ON "sleep_sessions" USING btree ("sleepDataSource");
CREATE INDEX "idx_sleep_sessions_date_source" ON "sleep_sessions" USING btree ("sessionDate", "sleepDataSource");

--
-- MIGRATION VERSION FOR insomniabutler
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('insomniabutler', '20260126132342953', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260126132342953', "timestamp" = now();

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
