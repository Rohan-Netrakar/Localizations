CREATE TABLE rooms (
    id SERIAL PRIMARY KEY,
    room_name VARCHAR(50) NOT NULL UNIQUE,
    floor VARCHAR(20),
    building VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



CREATE TABLE room_bssids (
    id SERIAL PRIMARY KEY,
    room_id INT NOT NULL,
    bssid VARCHAR(50) NOT NULL UNIQUE,
    band VARCHAR(10),            -- 2.4GHz / 5GHz
    ssid_name VARCHAR(50),       -- GITAM / GITAM_5G
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_room
      FOREIGN KEY (room_id)
      REFERENCES rooms(id)
      ON DELETE CASCADE
);


CREATE INDEX idx_room_bssids_bssid
ON room_bssids(bssid);


CREATE TABLE user_locations (
    user_id     VARCHAR(100) PRIMARY KEY,
    room_id     INT NOT NULL,
    x_pos       FLOAT DEFAULT 0,
    z_pos       FLOAT DEFAULT 0,
    last_seen   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_room
      FOREIGN KEY (room_id)
      REFERENCES rooms(id)
      ON DELETE CASCADE
);

CREATE INDEX idx_user_locations_room_id
ON user_locations(room_id);

CREATE INDEX idx_user_locations_last_seen
ON user_locations(last_seen DESC);

/* ── History log: one row per user-enters-room event ── */
CREATE TABLE IF NOT EXISTS location_history (
    id          SERIAL PRIMARY KEY,
    user_id     VARCHAR(100) NOT NULL,
    room_id     INT NOT NULL,
    entered_at  TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT fk_lh_room FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE CASCADE
);
CREATE INDEX idx_lh_room_id    ON location_history(room_id);
CREATE INDEX idx_lh_entered_at ON location_history(entered_at DESC);
CREATE INDEX idx_lh_user_id    ON location_history(user_id);

/* ── Room status tags (exam, cleaning, reserved, closed) ── */
CREATE TABLE IF NOT EXISTS room_reservations (
    id         SERIAL PRIMARY KEY,
    room_name  VARCHAR(50) NOT NULL UNIQUE,
    tag        VARCHAR(20) NOT NULL,
    label      VARCHAR(100) NOT NULL,
    set_by     VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- Migration: Fix timezone-naive TIMESTAMP columns
-- Run this ONCE on your existing database.
-- Changes TIMESTAMP → TIMESTAMPTZ so PostgreSQL
-- returns proper UTC timestamps to Node.js/JS.
-- =====================================================

-- user_locations.last_seen
ALTER TABLE user_locations
  ALTER COLUMN last_seen TYPE TIMESTAMPTZ
  USING last_seen AT TIME ZONE 'UTC';

ALTER TABLE user_locations
  ALTER COLUMN last_seen SET DEFAULT NOW();

-- rooms.created_at
ALTER TABLE rooms
  ALTER COLUMN created_at TYPE TIMESTAMPTZ
  USING created_at AT TIME ZONE 'UTC';

ALTER TABLE rooms
  ALTER COLUMN created_at SET DEFAULT NOW();

-- room_bssids.created_at
ALTER TABLE room_bssids
  ALTER COLUMN created_at TYPE TIMESTAMPTZ
  USING created_at AT TIME ZONE 'UTC';

ALTER TABLE room_bssids
  ALTER COLUMN created_at SET DEFAULT NOW();

-- Verify
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name IN ('user_locations','rooms','room_bssids')
  AND column_name IN ('last_seen','created_at')
ORDER BY table_name, column_name;

-- ============================================================
--  INDOOR LOCALIZATION — FULL DATABASE RESTORE SCRIPT
--  Run this on your fresh Render PostgreSQL database.
--  Steps: Create tables → Insert data → Fix sequences
-- ============================================================

-- ============================================================
--  SECTION 1: CREATE TABLES
-- ============================================================

CREATE TABLE rooms (
    id          SERIAL PRIMARY KEY,
    room_name   VARCHAR(50) NOT NULL UNIQUE,
    floor       VARCHAR(20),
    building    VARCHAR(50),
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE room_bssids (
    id          SERIAL PRIMARY KEY,
    room_id     INT NOT NULL,
    bssid       VARCHAR(50) NOT NULL UNIQUE,
    band        VARCHAR(10),
    ssid_name   VARCHAR(50),
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT fk_room
      FOREIGN KEY (room_id)
      REFERENCES rooms(id)
      ON DELETE CASCADE
);

CREATE INDEX idx_room_bssids_bssid ON room_bssids(bssid);

CREATE TABLE user_locations (
    user_id     VARCHAR(100) PRIMARY KEY,
    room_id     INT NOT NULL,
    x_pos       FLOAT DEFAULT 0,
    z_pos       FLOAT DEFAULT 0,
    last_seen   TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT fk_user_room
      FOREIGN KEY (room_id)
      REFERENCES rooms(id)
      ON DELETE CASCADE
);

CREATE INDEX idx_user_locations_room_id   ON user_locations(room_id);
CREATE INDEX idx_user_locations_last_seen ON user_locations(last_seen DESC);

CREATE TABLE location_history (
    id          SERIAL PRIMARY KEY,
    user_id     VARCHAR(100) NOT NULL,
    room_id     INT NOT NULL,
    entered_at  TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT fk_lh_room FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE CASCADE
);

CREATE INDEX idx_lh_room_id    ON location_history(room_id);
CREATE INDEX idx_lh_entered_at ON location_history(entered_at DESC);
CREATE INDEX idx_lh_user_id    ON location_history(user_id);

CREATE TABLE room_reservations (
    id         SERIAL PRIMARY KEY,
    room_name  VARCHAR(50) NOT NULL UNIQUE,
    tag        VARCHAR(20) NOT NULL,
    label      VARCHAR(100) NOT NULL,
    set_by     VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
--  SECTION 2: INSERT DATA
-- ============================================================

-- ---- rooms ----

INSERT INTO rooms (id, room_name, floor, building, created_at) OVERRIDING SYSTEM VALUE VALUES (5, '302', NULL, NULL, '2026-02-10 07:13:19.25426+00');
INSERT INTO rooms (id, room_name, floor, building, created_at) OVERRIDING SYSTEM VALUE VALUES (6, '303', NULL, NULL, '2026-02-10 07:13:57.892793+00');
INSERT INTO rooms (id, room_name, floor, building, created_at) OVERRIDING SYSTEM VALUE VALUES (7, '304', NULL, NULL, '2026-02-10 07:15:40.238303+00');
INSERT INTO rooms (id, room_name, floor, building, created_at) OVERRIDING SYSTEM VALUE VALUES (8, '305', NULL, NULL, '2026-02-10 07:16:21.437337+00');
INSERT INTO rooms (id, room_name, floor, building, created_at) OVERRIDING SYSTEM VALUE VALUES (9, '306', NULL, NULL, '2026-02-10 07:17:10.989309+00');
INSERT INTO rooms (id, room_name, floor, building, created_at) OVERRIDING SYSTEM VALUE VALUES (10, '307', NULL, NULL, '2026-02-10 07:20:27.087992+00');
INSERT INTO rooms (id, room_name, floor, building, created_at) OVERRIDING SYSTEM VALUE VALUES (11, '308', NULL, NULL, '2026-02-10 07:21:34.88112+00');
INSERT INTO rooms (id, room_name, floor, building, created_at) OVERRIDING SYSTEM VALUE VALUES (12, '309', NULL, NULL, '2026-02-10 07:22:38.639438+00');
INSERT INTO rooms (id, room_name, floor, building, created_at) OVERRIDING SYSTEM VALUE VALUES (13, '310', NULL, NULL, '2026-02-10 07:24:12.353744+00');
INSERT INTO rooms (id, room_name, floor, building, created_at) OVERRIDING SYSTEM VALUE VALUES (14, '311', NULL, NULL, '2026-02-10 07:25:55.151428+00');

-- ---- room_bssids ----
INSERT INTO room_bssids (id, room_id, bssid, band, ssid_name, created_at) OVERRIDING SYSTEM VALUE VALUES (1, 14, '48:8b:0a:5d:bc:21', '2.4 GHz', 'GITAM-5GHz', '2026-03-16 04:54:06.040095+00');
INSERT INTO room_bssids (id, room_id, bssid, band, ssid_name, created_at) OVERRIDING SYSTEM VALUE VALUES (2, 14, '48:8b:0a:5d:bc:20', '2.4 GHz', 'GITAM', '2026-03-16 04:54:22.806512+00');
INSERT INTO room_bssids (id, room_id, bssid, band, ssid_name, created_at) OVERRIDING SYSTEM VALUE VALUES (3, 14, '48:8b:0a:5d:de:ae', '5 GHz', 'GITAM-5GHz', '2026-03-16 08:28:54.322634+00');
INSERT INTO room_bssids (id, room_id, bssid, band, ssid_name, created_at) OVERRIDING SYSTEM VALUE VALUES (4, 13, '08:45:d1:95:82:c0', '2.4 GHz', 'GITAM', '2026-03-16 08:31:43.265979+00');
INSERT INTO room_bssids (id, room_id, bssid, band, ssid_name, created_at) OVERRIDING SYSTEM VALUE VALUES (5, 9, '08:45:d1:95:c8:0f', '5 GHz', 'GITAM', '2026-03-16 08:35:30.695916+00');
INSERT INTO room_bssids (id, room_id, bssid, band, ssid_name, created_at) OVERRIDING SYSTEM VALUE VALUES (6, 14, '48:8b:0a:5d:bc:2e', '5 GHz', 'GITAM-5GHz', '2026-03-16 09:21:12.315743+00');
INSERT INTO room_bssids (id, room_id, bssid, band, ssid_name, created_at) OVERRIDING SYSTEM VALUE VALUES (8, 5, '10:f9:20:ca:06:8d', '5GHz', 'GITAM', '2026-02-10 07:13:19.288748+00');
INSERT INTO room_bssids (id, room_id, bssid, band, ssid_name, created_at) OVERRIDING SYSTEM VALUE VALUES (10, 6, '48:8b:0a:d4:aa:8d', '5GHz', 'GITAM', '2026-02-10 07:13:57.92428+00');
INSERT INTO room_bssids (id, room_id, bssid, band, ssid_name, created_at) OVERRIDING SYSTEM VALUE VALUES (11, 6, '48:8b:0a:d4:aa:83', '2.4GHz', 'GITAM-5GHz', '2026-02-10 07:14:37.09293+00');
INSERT INTO room_bssids (id, room_id, bssid, band, ssid_name, created_at) OVERRIDING SYSTEM VALUE VALUES (12, 6, '48:8b:0a:d4:aa:8c', '5GHz', 'GITAM-5GHz', '2026-02-10 07:15:03.54759+00');
INSERT INTO room_bssids (id, room_id, bssid, band, ssid_name, created_at) OVERRIDING SYSTEM VALUE VALUES (13, 7, '10:f9:20:ca:06:cc', '5GHz', 'GITAM-5GHz', '2026-02-10 07:15:40.267844+00');
INSERT INTO room_bssids (id, room_id, bssid, band, ssid_name, created_at) OVERRIDING SYSTEM VALUE VALUES (14, 7, '08:45:d1:95:4f:2f', '5GHz', 'GITAM', '2026-02-10 07:15:53.521484+00');
INSERT INTO room_bssids (id, room_id, bssid, band, ssid_name, created_at) OVERRIDING SYSTEM VALUE VALUES (15, 8, '08:45:d1:94:b8:ef', '5GHz', 'GITAM', '2026-02-10 07:16:21.471406+00');
INSERT INTO room_bssids (id, room_id, bssid, band, ssid_name, created_at) OVERRIDING SYSTEM VALUE VALUES (16, 8, '08:45:d1:94:b8:ee', '5GHz', 'GITAM-5GHz', '2026-02-10 07:16:30.039569+00');
INSERT INTO room_bssids (id, room_id, bssid, band, ssid_name, created_at) OVERRIDING SYSTEM VALUE VALUES (17, 9, 'f0:1d:2d:f5:ea:2d', '5GHz', 'GITAM', '2026-02-10 07:17:11.020859+00');
INSERT INTO room_bssids (id, room_id, bssid, band, ssid_name, created_at) OVERRIDING SYSTEM VALUE VALUES (18, 9, '08:45:d1:95:c8:0e', '5GHz', 'GITAM-5GHz', '2026-02-10 07:17:22.20998+00');
INSERT INTO room_bssids (id, room_id, bssid, band, ssid_name, created_at) OVERRIDING SYSTEM VALUE VALUES (19, 10, '48:8b:0a:d5:38:e1', '2.4GHz', 'GITAM-5GHz', '2026-02-10 07:20:27.129561+00');
INSERT INTO room_bssids (id, room_id, bssid, band, ssid_name, created_at) OVERRIDING SYSTEM VALUE VALUES (20, 10, '48:8b:0a:d5:38:e0', '2.4GHz', 'GITAM', '2026-02-10 07:21:04.201003+00');
INSERT INTO room_bssids (id, room_id, bssid, band, ssid_name, created_at) OVERRIDING SYSTEM VALUE VALUES (21, 11, '48:8b:0a:d4:97:c0', '2.4GHz', 'GITAM', '2026-02-10 07:21:34.91222+00');
INSERT INTO room_bssids (id, room_id, bssid, band, ssid_name, created_at) OVERRIDING SYSTEM VALUE VALUES (22, 11, '08:45:d1:99:0b:a1', '2.4GHz', 'GITAM-5GHz', '2026-02-10 07:21:46.438411+00');
INSERT INTO room_bssids (id, room_id, bssid, band, ssid_name, created_at) OVERRIDING SYSTEM VALUE VALUES (23, 12, '08:45:d1:97:2b:4f', '5 GHz', 'GITAM', '2026-04-06 09:27:23.748448+00');
INSERT INTO room_bssids (id, room_id, bssid, band, ssid_name, created_at) OVERRIDING SYSTEM VALUE VALUES (24, 12, '08:45:d1:98:f9:e1', '2.4 GHz', 'GITAM-5GHz', '2026-04-06 09:27:34.574453+00');
INSERT INTO room_bssids (id, room_id, bssid, band, ssid_name, created_at) OVERRIDING SYSTEM VALUE VALUES (25, 13, '08:45:d1:95:82:cf', '5GHz', 'GITAM', '2026-02-10 07:24:12.397403+00');
INSERT INTO room_bssids (id, room_id, bssid, band, ssid_name, created_at) OVERRIDING SYSTEM VALUE VALUES (26, 12, '08:45:d1:98:f9:e0', '2.4 GHz', 'GITAM', '2026-04-06 09:30:43.826493+00');
INSERT INTO room_bssids (id, room_id, bssid, band, ssid_name, created_at) OVERRIDING SYSTEM VALUE VALUES (27, 14, '08:45:d1:95:82:ce', '5GHz', 'GITAM-5GHz', '2026-02-10 07:25:55.184256+00');
INSERT INTO room_bssids (id, room_id, bssid, band, ssid_name, created_at) OVERRIDING SYSTEM VALUE VALUES (32, 14, '48:8b:0a:5d:bc:2f', '5GHz', 'GITAM', '2026-02-10 07:27:18.688621+00');

-- ---- user_locations ----
INSERT INTO user_locations (user_id, room_id, x_pos, z_pos, last_seen) VALUES ('anusha', 6, 0, 0, '2026-03-13 05:52:48.513623+00');
INSERT INTO user_locations (user_id, room_id, x_pos, z_pos, last_seen) VALUES ('Bhoomika', 14, 0, 0, '2026-03-16 08:29:59.938419+00');
INSERT INTO user_locations (user_id, room_id, x_pos, z_pos, last_seen) VALUES ('ROHAN A NETRAKAR', 9, 0, 0, '2026-04-06 10:02:41.279766+00');
INSERT INTO user_locations (user_id, room_id, x_pos, z_pos, last_seen) VALUES ('SRUJANA', 12, 0, 0, '2026-04-06 09:28:51.770716+00');

-- ---- location_history ----
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (1, 'anusha', 6, '2026-03-13 05:52:48.750398+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (2, 'ROHAN A NETRAKAR', 9, '2026-03-13 06:51:43.214448+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (3, 'ROHAN A NETRAKAR', 9, '2026-03-13 06:51:59.136135+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (4, 'ROHAN A NETRAKAR', 9, '2026-03-13 06:52:15.016713+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (5, 'ROHAN A NETRAKAR', 9, '2026-03-13 06:52:30.846064+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (6, 'ROHAN A NETRAKAR', 9, '2026-03-13 06:52:46.547734+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (7, 'ROHAN A NETRAKAR', 9, '2026-03-13 06:53:02.324617+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (8, 'ROHAN A NETRAKAR', 9, '2026-03-13 06:53:17.993509+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (9, 'ROHAN A NETRAKAR', 9, '2026-03-13 06:53:33.729814+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (10, 'ROHAN A NETRAKAR', 9, '2026-03-13 06:53:49.49487+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (11, 'ROHAN A NETRAKAR', 9, '2026-03-13 06:54:05.277473+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (12, 'ROHAN A NETRAKAR', 9, '2026-03-13 06:54:21.032864+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (13, 'ROHAN A NETRAKAR', 9, '2026-03-13 06:54:36.831239+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (14, 'ROHAN A NETRAKAR', 9, '2026-03-13 06:54:52.650961+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (15, 'ROHAN A NETRAKAR', 9, '2026-03-13 06:55:08.394364+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (16, 'ROHAN A NETRAKAR', 9, '2026-03-13 06:55:24.107817+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (17, 'ROHAN A NETRAKAR', 9, '2026-03-13 06:55:40.070627+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (18, 'ROHAN A NETRAKAR', 9, '2026-03-13 06:55:55.84371+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (19, 'ROHAN A NETRAKAR', 9, '2026-03-13 06:56:11.64309+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (20, 'ROHAN A NETRAKAR', 9, '2026-03-13 06:56:27.372375+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (21, 'ROHAN A NETRAKAR', 9, '2026-03-13 06:56:43.069719+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (22, 'ROHAN A NETRAKAR', 9, '2026-03-13 06:56:58.887149+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (23, 'ROHAN A NETRAKAR', 9, '2026-03-13 06:57:14.675481+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (24, 'ROHAN A NETRAKAR', 9, '2026-03-13 06:57:30.632638+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (25, 'ROHAN A NETRAKAR', 9, '2026-03-13 06:57:46.389286+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (26, 'ROHAN A NETRAKAR', 9, '2026-03-13 06:58:02.222056+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (27, 'ROHAN A NETRAKAR', 9, '2026-03-13 06:58:18.061687+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (28, 'ROHAN A NETRAKAR', 9, '2026-03-13 06:58:33.820767+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (29, 'ROHAN A NETRAKAR', 9, '2026-03-13 06:58:49.689429+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (30, 'ROHAN A NETRAKAR', 9, '2026-03-13 06:59:05.614932+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (31, 'ROHAN A NETRAKAR', 9, '2026-03-13 06:59:21.452286+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (32, 'ROHAN A NETRAKAR', 9, '2026-03-13 06:59:37.196145+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (33, 'ROHAN A NETRAKAR', 9, '2026-03-13 06:59:52.93897+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (34, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:00:08.928983+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (35, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:00:24.683856+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (36, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:00:40.639589+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (37, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:00:57.954804+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (38, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:01:13.728416+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (39, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:01:29.577307+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (40, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:01:45.274977+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (41, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:02:01.126184+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (42, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:02:17.032046+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (43, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:02:32.748618+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (44, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:02:48.876788+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (45, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:03:04.699637+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (46, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:03:20.609757+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (47, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:03:36.355454+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (48, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:03:52.049592+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (49, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:04:07.837207+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (50, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:04:23.650726+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (51, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:04:39.607417+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (52, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:04:55.31239+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (53, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:05:11.127609+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (54, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:05:26.891499+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (55, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:05:42.837183+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (56, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:05:58.773044+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (57, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:06:14.546286+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (58, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:06:30.765052+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (59, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:06:46.484901+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (60, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:07:02.323897+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (61, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:07:18.112701+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (62, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:07:33.767307+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (63, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:07:49.611566+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (64, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:08:05.452026+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (65, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:08:21.237486+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (66, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:08:36.976926+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (67, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:08:52.731827+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (68, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:09:08.661023+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (69, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:09:24.551965+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (70, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:09:40.401876+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (71, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:09:56.168473+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (72, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:10:11.921587+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (73, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:10:28.279688+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (74, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:10:44.033721+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (75, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:10:59.863351+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (76, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:11:15.73273+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (77, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:11:31.475911+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (78, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:11:47.254719+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (79, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:12:02.977133+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (80, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:12:19.139808+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (81, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:12:35.000188+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (82, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:12:50.761767+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (83, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:13:06.532183+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (84, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:13:22.21662+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (85, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:13:37.898999+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (86, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:13:53.644214+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (87, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:14:09.381718+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (88, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:14:25.08826+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (89, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:14:40.818869+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (90, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:14:56.514899+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (91, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:15:12.269993+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (92, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:15:28.402743+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (93, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:15:44.291735+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (94, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:15:59.978141+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (95, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:16:15.686012+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (96, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:16:31.484633+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (97, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:16:47.165307+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (98, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:17:02.897959+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (99, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:17:18.612225+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (100, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:17:34.310755+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (101, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:17:49.973793+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (102, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:18:05.698836+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (103, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:18:21.377911+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (104, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:18:37.10048+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (105, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:18:52.876521+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (106, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:19:08.614503+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (107, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:19:24.43086+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (108, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:19:40.102264+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (109, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:19:55.798712+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (110, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:20:11.56272+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (111, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:20:27.217801+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (112, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:20:42.95487+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (113, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:20:58.630401+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (114, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:21:14.364635+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (115, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:21:30.120721+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (116, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:21:45.802419+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (117, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:22:01.531384+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (118, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:22:17.637238+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (119, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:22:33.328958+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (120, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:22:49.651752+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (121, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:23:05.477172+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (122, 'ROHAN A NETRAKAR', 9, '2026-03-13 07:23:40.837663+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (123, 'ROHAN A NETRAKAR', 9, '2026-03-13 09:08:54.172324+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (124, 'ROHAN A NETRAKAR', 9, '2026-03-13 09:08:56.022334+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (125, 'ROHAN A NETRAKAR', 9, '2026-03-13 09:09:11.762294+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (126, 'ROHAN A NETRAKAR', 9, '2026-03-13 09:09:27.497936+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (127, 'ROHAN A NETRAKAR', 9, '2026-03-13 09:09:43.052798+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (128, 'ROHAN A NETRAKAR', 9, '2026-03-13 09:09:58.954728+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (129, 'ROHAN A NETRAKAR', 9, '2026-03-13 09:10:14.797465+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (130, 'ROHAN A NETRAKAR', 9, '2026-03-13 09:10:30.407429+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (131, 'ROHAN A NETRAKAR', 9, '2026-03-13 09:10:46.374779+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (132, 'ROHAN A NETRAKAR', 9, '2026-03-13 09:11:02.319113+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (133, 'ROHAN A NETRAKAR', 9, '2026-03-13 09:11:18.250597+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (134, 'SRUJANA', 9, '2026-03-16 05:47:28.698156+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (135, 'SRUJANA', 9, '2026-03-16 05:47:44.562799+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (136, 'SRUJANA', 9, '2026-03-16 05:48:11.200672+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (137, 'SRUJANA', 9, '2026-03-16 05:48:26.904543+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (138, 'SRUJANA', 9, '2026-03-16 05:49:15.302727+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (139, 'SRUJANA', 9, '2026-03-16 05:49:31.087911+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (140, 'SRUJANA', 9, '2026-03-16 05:50:10.927887+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (141, 'SRUJANA', 9, '2026-03-16 05:50:26.691838+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (142, 'SRUJANA', 9, '2026-03-16 05:50:42.529466+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (143, 'SRUJANA', 9, '2026-03-16 05:50:58.338614+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (144, 'SRUJANA', 9, '2026-03-16 05:51:14.165346+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (145, 'SRUJANA', 9, '2026-03-16 05:51:32.83715+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (146, 'SRUJANA', 9, '2026-03-16 05:51:48.841877+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (147, 'SRUJANA', 9, '2026-03-16 05:52:21.77774+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (148, 'SRUJANA', 9, '2026-03-16 05:52:37.583752+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (149, 'SRUJANA', 9, '2026-03-16 05:53:05.617539+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (150, 'SRUJANA', 9, '2026-03-16 05:53:21.43545+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (151, 'SRUJANA', 9, '2026-03-16 05:53:59.753319+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (152, 'SRUJANA', 9, '2026-03-16 05:54:15.482337+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (153, 'SRUJANA', 9, '2026-03-16 05:54:31.240967+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (154, 'SRUJANA', 9, '2026-03-16 05:54:47.001884+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (155, 'SRUJANA', 9, '2026-03-16 05:55:02.860123+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (156, 'SRUJANA', 9, '2026-03-16 05:55:18.658613+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (157, 'SRUJANA', 9, '2026-03-16 05:55:34.456995+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (158, 'SRUJANA', 9, '2026-03-16 05:55:50.310927+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (159, 'SRUJANA', 9, '2026-03-16 05:56:06.339201+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (160, 'SRUJANA', 9, '2026-03-16 05:56:22.234722+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (161, 'SRUJANA', 9, '2026-03-16 05:56:38.125518+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (162, 'SRUJANA', 9, '2026-03-16 05:56:53.87863+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (163, 'SRUJANA', 9, '2026-03-16 05:57:10.374788+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (164, 'SRUJANA', 9, '2026-03-16 05:57:26.138493+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (165, 'SRUJANA', 9, '2026-03-16 05:57:41.921728+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (166, 'SRUJANA', 9, '2026-03-16 05:57:57.74572+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (167, 'SRUJANA', 9, '2026-03-16 05:58:13.604739+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (168, 'SRUJANA', 9, '2026-03-16 05:58:29.730003+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (169, 'SRUJANA', 9, '2026-03-16 05:58:56.221323+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (170, 'SRUJANA', 9, '2026-03-16 05:59:12.020885+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (171, 'SRUJANA', 9, '2026-03-16 05:59:49.59083+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (172, 'SRUJANA', 9, '2026-03-16 06:00:06.068514+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (173, 'SRUJANA', 9, '2026-03-16 06:00:40.709717+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (174, 'SRUJANA', 9, '2026-03-16 06:00:56.593511+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (175, 'SRUJANA', 9, '2026-03-16 06:01:23.530841+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (176, 'SRUJANA', 9, '2026-03-16 06:01:39.366383+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (177, 'SRUJANA', 9, '2026-03-16 06:02:13.130277+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (178, 'SRUJANA', 9, '2026-03-16 06:02:29.795576+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (179, 'SRUJANA', 9, '2026-03-16 06:02:48.626043+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (180, 'SRUJANA', 9, '2026-03-16 06:03:04.481083+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (181, 'SRUJANA', 9, '2026-03-16 06:03:24.326938+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (182, 'SRUJANA', 9, '2026-03-16 06:03:40.227053+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (183, 'SRUJANA', 9, '2026-03-16 06:04:09.050212+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (184, 'SRUJANA', 9, '2026-03-16 06:04:25.433429+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (185, 'SRUJANA', 9, '2026-03-16 06:05:07.44115+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (186, 'SRUJANA', 9, '2026-03-16 06:05:23.373725+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (187, 'SRUJANA', 9, '2026-03-16 06:05:39.19118+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (188, 'SRUJANA', 9, '2026-03-16 06:05:56.548462+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (189, 'SRUJANA', 9, '2026-03-16 06:06:18.928606+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (190, 'SRUJANA', 9, '2026-03-16 06:06:56.213767+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (191, 'SRUJANA', 9, '2026-03-16 06:07:12.382556+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (192, 'SRUJANA', 9, '2026-03-16 06:07:45.186175+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (193, 'SRUJANA', 9, '2026-03-16 06:08:01.138722+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (194, 'SRUJANA', 9, '2026-03-16 06:08:23.478969+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (195, 'SRUJANA', 9, '2026-03-16 06:08:39.290475+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (196, 'SRUJANA', 9, '2026-03-16 06:09:03.207837+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (197, 'SRUJANA', 9, '2026-03-16 06:09:19.006456+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (198, 'SRUJANA', 9, '2026-03-16 06:09:34.764887+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (199, 'SRUJANA', 9, '2026-03-16 06:09:50.717553+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (200, 'SRUJANA', 9, '2026-03-16 06:10:21.277931+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (201, 'SRUJANA', 9, '2026-03-16 06:10:37.0783+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (202, 'SRUJANA', 9, '2026-03-16 06:11:04.255165+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (203, 'SRUJANA', 9, '2026-03-16 06:11:20.051918+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (204, 'SRUJANA', 9, '2026-03-16 06:11:48.223906+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (205, 'SRUJANA', 9, '2026-03-16 06:12:03.957079+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (206, 'SRUJANA', 9, '2026-03-16 06:12:40.697426+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (207, 'SRUJANA', 9, '2026-03-16 06:12:56.514223+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (208, 'SRUJANA', 9, '2026-03-16 06:13:32.612721+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (209, 'SRUJANA', 9, '2026-03-16 06:13:48.468083+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (210, 'SRUJANA', 9, '2026-03-16 06:14:08.953185+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (211, 'SRUJANA', 9, '2026-03-16 06:14:24.768287+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (212, 'SRUJANA', 9, '2026-03-16 06:14:56.749315+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (213, 'SRUJANA', 9, '2026-03-16 06:15:13.084713+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (214, 'SRUJANA', 9, '2026-03-16 06:15:29.07378+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (215, 'SRUJANA', 9, '2026-03-16 06:15:44.895752+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (216, 'SRUJANA', 9, '2026-03-16 06:16:00.758381+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (217, 'SRUJANA', 9, '2026-03-16 06:16:16.658122+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (218, 'SRUJANA', 9, '2026-03-16 06:16:32.408392+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (219, 'SRUJANA', 9, '2026-03-16 06:16:48.255822+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (220, 'SRUJANA', 9, '2026-03-16 06:17:03.980715+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (221, 'SRUJANA', 9, '2026-03-16 06:17:19.78572+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (222, 'SRUJANA', 9, '2026-03-16 06:17:36.153063+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (223, 'SRUJANA', 9, '2026-03-16 06:17:51.907426+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (224, 'SRUJANA', 9, '2026-03-16 06:18:07.741076+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (225, 'SRUJANA', 9, '2026-03-16 06:18:23.563705+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (226, 'SRUJANA', 9, '2026-03-16 06:18:39.444996+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (227, 'SRUJANA', 9, '2026-03-16 06:18:55.255714+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (228, 'SRUJANA', 9, '2026-03-16 06:19:11.194085+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (229, 'SRUJANA', 9, '2026-03-16 06:19:26.999881+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (230, 'SRUJANA', 9, '2026-03-16 06:20:50.780637+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (231, 'SRUJANA', 9, '2026-03-16 06:21:22.838192+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (232, 'SRUJANA', 9, '2026-03-16 06:23:33.183577+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (233, 'SRUJANA', 9, '2026-03-16 06:24:18.934715+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (234, 'SRUJANA', 9, '2026-03-16 06:25:02.099733+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (235, 'SRUJANA', 9, '2026-03-16 06:25:17.855094+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (236, 'SRUJANA', 9, '2026-03-16 06:25:52.402077+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (237, 'SRUJANA', 9, '2026-03-16 06:26:08.22063+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (238, 'SRUJANA', 9, '2026-03-16 06:27:00.972179+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (239, 'SRUJANA', 9, '2026-03-16 06:27:16.852545+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (240, 'SRUJANA', 9, '2026-03-16 06:27:36.850734+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (241, 'SRUJANA', 9, '2026-03-16 06:29:02.831182+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (242, 'SRUJANA', 9, '2026-03-16 06:29:18.558818+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (243, 'SRUJANA', 9, '2026-03-16 06:30:05.973013+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (244, 'SRUJANA', 9, '2026-03-16 06:30:22.332236+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (245, 'SRUJANA', 9, '2026-03-16 06:30:38.139974+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (246, 'SRUJANA', 9, '2026-03-16 06:30:53.946509+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (247, 'SRUJANA', 9, '2026-03-16 06:32:56.177298+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (248, 'SRUJANA', 9, '2026-03-16 06:34:13.565629+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (249, 'SRUJANA', 9, '2026-03-16 06:34:30.849426+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (250, 'SRUJANA', 9, '2026-03-16 06:35:19.654618+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (251, 'SRUJANA', 9, '2026-03-16 06:36:03.760537+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (252, 'SRUJANA', 9, '2026-03-16 06:36:32.328502+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (253, 'SRUJANA', 9, '2026-03-16 06:36:48.136344+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (254, 'SRUJANA', 9, '2026-03-16 06:37:04.405612+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (255, 'SRUJANA', 9, '2026-03-16 06:37:20.475459+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (256, 'SRUJANA', 9, '2026-03-16 06:37:36.350961+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (257, 'SRUJANA', 9, '2026-03-16 06:37:52.218022+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (258, 'SRUJANA', 9, '2026-03-16 06:38:08.455018+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (259, 'SRUJANA', 9, '2026-03-16 06:38:24.251965+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (260, 'SRUJANA', 9, '2026-03-16 06:38:50.814496+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (261, 'SRUJANA', 9, '2026-03-16 06:39:06.565176+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (262, 'SRUJANA', 9, '2026-03-16 06:40:11.003541+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (263, 'SRUJANA', 9, '2026-03-16 06:40:27.259528+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (264, 'SRUJANA', 9, '2026-03-16 06:41:20.049724+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (265, 'SRUJANA', 9, '2026-03-16 06:41:35.906721+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (266, 'SRUJANA', 9, '2026-03-16 06:41:59.933024+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (267, 'SRUJANA', 9, '2026-03-16 06:42:35.908232+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (268, 'SRUJANA', 9, '2026-03-16 06:42:51.72872+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (269, 'SRUJANA', 9, '2026-03-16 06:43:07.965087+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (270, 'SRUJANA', 9, '2026-03-16 06:43:23.720012+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (271, 'SRUJANA', 9, '2026-03-16 06:43:39.493714+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (272, 'SRUJANA', 9, '2026-03-16 06:43:55.337964+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (273, 'SRUJANA', 9, '2026-03-16 06:44:11.087861+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (274, 'SRUJANA', 9, '2026-03-16 06:44:26.882754+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (275, 'SRUJANA', 9, '2026-03-16 06:44:43.157408+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (276, 'SRUJANA', 9, '2026-03-16 06:44:58.99493+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (277, 'SRUJANA', 9, '2026-03-16 06:45:14.764337+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (278, 'SRUJANA', 9, '2026-03-16 06:45:30.634198+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (279, 'SRUJANA', 9, '2026-03-16 06:45:46.858371+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (280, 'SRUJANA', 9, '2026-03-16 06:46:03.032526+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (281, 'SRUJANA', 9, '2026-03-16 06:46:18.777733+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (282, 'SRUJANA', 9, '2026-03-16 06:46:34.536477+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (283, 'SRUJANA', 9, '2026-03-16 06:46:50.301159+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (284, 'SRUJANA', 9, '2026-03-16 06:47:06.280051+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (285, 'SRUJANA', 9, '2026-03-16 06:47:22.112726+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (286, 'SRUJANA', 9, '2026-03-16 06:47:37.872552+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (287, 'SRUJANA', 9, '2026-03-16 06:47:53.68619+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (288, 'SRUJANA', 9, '2026-03-16 06:48:09.647413+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (289, 'SRUJANA', 9, '2026-03-16 06:48:25.406567+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (290, 'SRUJANA', 9, '2026-03-16 06:48:41.289328+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (291, 'SRUJANA', 9, '2026-03-16 06:48:57.08197+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (292, 'SRUJANA', 9, '2026-03-16 06:49:12.78827+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (293, 'SRUJANA', 9, '2026-03-16 06:49:29.375574+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (294, 'SRUJANA', 9, '2026-03-16 06:49:45.644565+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (295, 'SRUJANA', 9, '2026-03-16 06:50:01.536716+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (296, 'SRUJANA', 9, '2026-03-16 06:50:17.417741+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (297, 'SRUJANA', 9, '2026-03-16 06:50:33.254312+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (298, 'SRUJANA', 9, '2026-03-16 06:50:49.017831+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (299, 'SRUJANA', 9, '2026-03-16 06:51:05.395063+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (300, 'SRUJANA', 9, '2026-03-16 06:51:21.192732+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (301, 'SRUJANA', 9, '2026-03-16 06:51:37.009546+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (302, 'SRUJANA', 9, '2026-03-16 06:51:52.738737+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (303, 'SRUJANA', 9, '2026-03-16 06:52:08.575908+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (304, 'SRUJANA', 9, '2026-03-16 06:52:24.332245+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (305, 'SRUJANA', 9, '2026-03-16 06:52:40.150422+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (306, 'SRUJANA', 9, '2026-03-16 06:52:55.979442+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (307, 'SRUJANA', 9, '2026-03-16 06:53:11.809845+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (308, 'SRUJANA', 9, '2026-03-16 06:53:27.614724+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (309, 'SRUJANA', 9, '2026-03-16 06:53:43.836813+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (310, 'SRUJANA', 9, '2026-03-16 06:53:59.692534+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (311, 'SRUJANA', 9, '2026-03-16 06:54:15.430101+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (312, 'SRUJANA', 9, '2026-03-16 06:54:31.276261+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (313, 'SRUJANA', 9, '2026-03-16 06:54:47.118052+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (314, 'SRUJANA', 9, '2026-03-16 06:57:36.846844+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (315, 'SRUJANA', 9, '2026-03-16 06:59:04.588147+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (316, 'SRUJANA', 9, '2026-03-16 06:59:43.827548+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (317, 'SRUJANA', 9, '2026-03-16 07:01:19.181923+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (318, 'SRUJANA', 9, '2026-03-16 07:01:49.817451+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (319, 'SRUJANA', 9, '2026-03-16 07:02:06.142759+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (320, 'SRUJANA', 9, '2026-03-16 07:02:21.901502+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (321, 'SRUJANA', 9, '2026-03-16 07:02:37.84308+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (322, 'SRUJANA', 9, '2026-03-16 07:02:54.144793+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (323, 'SRUJANA', 9, '2026-03-16 07:03:10.018354+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (324, 'SRUJANA', 9, '2026-03-16 07:03:26.324425+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (325, 'SRUJANA', 9, '2026-03-16 07:03:42.171046+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (326, 'SRUJANA', 9, '2026-03-16 07:03:58.054617+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (327, 'SRUJANA', 9, '2026-03-16 07:04:13.850114+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (328, 'SRUJANA', 9, '2026-03-16 07:04:30.163433+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (329, 'SRUJANA', 9, '2026-03-16 07:04:45.957724+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (330, 'SRUJANA', 9, '2026-03-16 07:05:09.606004+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (331, 'SRUJANA', 9, '2026-03-16 07:05:25.302153+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (332, 'SRUJANA', 9, '2026-03-16 07:05:41.244513+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (333, 'SRUJANA', 9, '2026-03-16 07:06:04.973685+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (334, 'SRUJANA', 9, '2026-03-16 07:06:26.476933+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (335, 'SRUJANA', 9, '2026-03-16 07:06:42.829818+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (336, 'SRUJANA', 9, '2026-03-16 07:06:58.771716+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (337, 'SRUJANA', 9, '2026-03-16 07:07:14.655576+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (338, 'SRUJANA', 9, '2026-03-16 07:07:30.635713+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (339, 'SRUJANA', 9, '2026-03-16 07:07:47.951277+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (340, 'SRUJANA', 9, '2026-03-16 07:08:03.69851+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (341, 'SRUJANA', 9, '2026-03-16 07:08:19.439619+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (342, 'SRUJANA', 9, '2026-03-16 07:08:35.365067+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (343, 'SRUJANA', 9, '2026-03-16 07:08:51.246081+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (344, 'SRUJANA', 9, '2026-03-16 07:09:07.408106+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (345, 'SRUJANA', 9, '2026-03-16 07:09:23.150846+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (346, 'SRUJANA', 9, '2026-03-16 07:09:38.913203+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (347, 'SRUJANA', 9, '2026-03-16 07:09:55.315816+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (348, 'SRUJANA', 9, '2026-03-16 07:10:11.183611+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (349, 'SRUJANA', 9, '2026-03-16 07:10:26.925344+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (350, 'SRUJANA', 9, '2026-03-16 07:10:42.723714+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (351, 'SRUJANA', 9, '2026-03-16 07:10:58.604742+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (352, 'SRUJANA', 9, '2026-03-16 07:11:14.461096+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (353, 'SRUJANA', 9, '2026-03-16 07:11:30.373761+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (354, 'SRUJANA', 9, '2026-03-16 07:11:46.144118+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (355, 'SRUJANA', 9, '2026-03-16 07:12:02.131406+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (356, 'SRUJANA', 9, '2026-03-16 07:12:17.829574+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (357, 'SRUJANA', 9, '2026-03-16 07:12:33.58771+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (358, 'SRUJANA', 9, '2026-03-16 07:12:49.345757+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (359, 'SRUJANA', 9, '2026-03-16 07:13:09.884535+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (360, 'SRUJANA', 9, '2026-03-16 07:13:25.665999+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (361, 'SRUJANA', 9, '2026-03-16 07:13:41.561894+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (362, 'SRUJANA', 9, '2026-03-16 07:13:57.442082+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (363, 'SRUJANA', 9, '2026-03-16 07:14:13.210237+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (364, 'SRUJANA', 9, '2026-03-16 07:14:29.417413+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (365, 'SRUJANA', 9, '2026-03-16 07:14:45.18436+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (366, 'SRUJANA', 9, '2026-03-16 07:15:01.131722+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (367, 'SRUJANA', 9, '2026-03-16 07:15:17.248427+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (368, 'SRUJANA', 9, '2026-03-16 07:15:33.028725+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (369, 'SRUJANA', 9, '2026-03-16 07:15:49.054013+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (370, 'SRUJANA', 9, '2026-03-16 07:16:04.75063+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (371, 'SRUJANA', 9, '2026-03-16 07:16:20.659435+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (372, 'SRUJANA', 9, '2026-03-16 07:16:36.479727+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (373, 'ROHAN A NETRAKAR', 13, '2026-03-16 08:28:07.228817+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (374, 'ROHAN A NETRAKAR', 13, '2026-03-16 08:28:23.385799+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (375, 'ROHAN A NETRAKAR', 14, '2026-03-16 08:28:38.869121+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (376, 'SRUJANA', 14, '2026-03-16 08:28:58.890716+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (377, 'SRUJANA', 14, '2026-03-16 08:29:14.783512+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (378, 'Bhoomika', 13, '2026-03-16 08:29:29.712628+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (379, 'SRUJANA', 14, '2026-03-16 08:29:30.379714+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (380, 'Bhoomika', 13, '2026-03-16 08:29:34.311077+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (381, 'Bhoomika', 13, '2026-03-16 08:29:41.640286+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (382, 'Bhoomika', 14, '2026-03-16 08:29:57.239723+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (383, 'Bhoomika', 14, '2026-03-16 08:29:59.967261+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (384, 'SRUJANA', 14, '2026-03-16 08:30:03.467219+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (385, 'SRUJANA', 14, '2026-03-16 08:30:19.268689+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (386, 'ROHAN A NETRAKAR', 14, '2026-03-16 08:30:21.545482+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (387, 'SRUJANA', 14, '2026-03-16 08:30:35.098925+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (388, 'ROHAN A NETRAKAR', 14, '2026-03-16 08:30:37.190714+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (389, 'SRUJANA', 14, '2026-03-16 08:30:50.63022+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (390, 'SRUJANA', 14, '2026-03-16 08:31:06.263717+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (391, 'SRUJANA', 14, '2026-03-16 08:31:22.05299+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (392, 'SRUJANA', 14, '2026-03-16 08:31:37.668932+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (393, 'ROHAN A NETRAKAR', 13, '2026-03-16 08:31:47.442944+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (394, 'ROHAN A NETRAKAR', 13, '2026-03-16 08:31:49.84923+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (395, 'SRUJANA', 14, '2026-03-16 08:31:53.196731+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (396, 'SRUJANA', 14, '2026-03-16 08:32:08.902025+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (397, 'ROHAN A NETRAKAR', 13, '2026-03-16 08:32:10.84488+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (398, 'ROHAN A NETRAKAR', 14, '2026-03-16 08:32:21.216485+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (399, 'SRUJANA', 14, '2026-03-16 08:32:24.4835+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (400, 'ROHAN A NETRAKAR', 14, '2026-03-16 08:32:37.090721+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (401, 'SRUJANA', 14, '2026-03-16 08:32:39.971714+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (402, 'SRUJANA', 13, '2026-03-16 08:32:56.668513+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (403, 'SRUJANA', 13, '2026-03-16 08:33:12.472734+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (404, 'ROHAN A NETRAKAR', 12, '2026-03-16 08:33:21.33707+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (405, 'ROHAN A NETRAKAR', 9, '2026-03-16 08:33:45.037324+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (406, 'ROHAN A NETRAKAR', 9, '2026-03-16 08:34:01.08881+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (407, 'ROHAN A NETRAKAR', 9, '2026-03-16 08:34:16.702946+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (408, 'ROHAN A NETRAKAR', 9, '2026-03-16 08:34:21.345021+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (409, 'ROHAN A NETRAKAR', 9, '2026-03-16 08:34:37.245496+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (410, 'ROHAN A NETRAKAR', 9, '2026-03-16 08:34:52.955703+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (411, 'ROHAN A NETRAKAR', 9, '2026-03-16 08:35:08.525872+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (412, 'ROHAN A NETRAKAR', 9, '2026-03-16 08:35:28.163357+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (413, 'SRUJANA', 9, '2026-03-16 08:35:35.522766+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (414, 'SRUJANA', 9, '2026-03-16 08:35:51.038895+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (415, 'ROHAN A NETRAKAR', 9, '2026-03-16 08:36:02.86885+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (416, 'SRUJANA', 9, '2026-03-16 08:36:06.773721+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (417, 'ROHAN A NETRAKAR', 9, '2026-03-16 08:36:19.180357+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (418, 'SRUJANA', 9, '2026-03-16 08:36:22.250921+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (419, 'SRUJANA', 9, '2026-03-16 08:36:38.131076+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (420, 'SRUJANA', 9, '2026-03-16 08:36:58.780554+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (421, 'ROHAN A NETRAKAR', 9, '2026-03-16 08:37:03.803465+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (422, 'SRUJANA', 9, '2026-03-16 08:37:14.544316+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (423, 'SRUJANA', 9, '2026-03-16 08:37:30.506687+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (424, 'SRUJANA', 9, '2026-03-16 08:37:46.653914+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (425, 'ROHAN A NETRAKAR', 9, '2026-03-16 08:37:53.106488+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (426, 'SRUJANA', 9, '2026-03-16 08:38:05.943713+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (427, 'ROHAN A NETRAKAR', 14, '2026-03-16 08:38:37.720272+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (428, 'SRUJANA', 14, '2026-03-16 08:38:43.449784+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (429, 'SRUJANA', 14, '2026-03-16 08:38:59.208292+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (430, 'SRUJANA', 14, '2026-03-16 08:39:15.07334+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (431, 'SRUJANA', 14, '2026-03-16 08:39:30.925842+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (432, 'ROHAN A NETRAKAR', 14, '2026-03-16 08:39:32.522662+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (433, 'SRUJANA', 14, '2026-03-16 08:39:46.743185+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (434, 'ROHAN A NETRAKAR', 14, '2026-03-16 08:39:59.905368+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (435, 'SRUJANA', 14, '2026-03-16 08:40:02.717499+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (436, 'SRUJANA', 14, '2026-03-16 08:40:18.187037+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (437, 'SRUJANA', 14, '2026-03-16 08:40:33.700081+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (438, 'SRUJANA', 14, '2026-03-16 08:40:49.511711+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (439, 'SRUJANA', 14, '2026-03-16 08:41:07.683804+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (440, 'SRUJANA', 14, '2026-03-16 08:41:23.446081+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (441, 'ROHAN A NETRAKAR', 14, '2026-03-16 08:43:33.120337+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (442, 'ROHAN A NETRAKAR', 14, '2026-03-16 08:43:48.929433+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (443, 'ROHAN A NETRAKAR', 14, '2026-03-16 08:45:44.471167+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (444, 'ROHAN A NETRAKAR', 14, '2026-03-16 08:47:05.900448+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (445, 'ROHAN A NETRAKAR', 14, '2026-03-16 08:47:21.809444+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (446, 'ROHAN A NETRAKAR', 14, '2026-03-16 08:47:37.689295+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (447, 'ROHAN A NETRAKAR', 14, '2026-03-16 08:47:53.570993+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (448, 'ROHAN A NETRAKAR', 14, '2026-03-16 08:48:09.41585+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (449, 'ROHAN A NETRAKAR', 14, '2026-03-16 08:48:25.312686+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (450, 'ROHAN A NETRAKAR', 14, '2026-03-16 08:48:41.136072+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (451, 'ROHAN A NETRAKAR', 14, '2026-03-16 08:49:21.274995+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (452, 'ROHAN A NETRAKAR', 14, '2026-03-16 08:51:42.526125+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (453, 'ROHAN A NETRAKAR', 14, '2026-03-16 08:51:58.386838+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (454, 'ROHAN A NETRAKAR', 14, '2026-03-16 08:53:02.150365+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (455, 'ROHAN A NETRAKAR', 14, '2026-03-16 08:54:39.33877+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (456, 'ROHAN A NETRAKAR', 14, '2026-03-16 08:54:55.167326+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (457, 'ROHAN A NETRAKAR', 14, '2026-03-16 09:02:33.902625+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (458, 'ROHAN A NETRAKAR', 14, '2026-03-16 09:04:50.62021+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (459, 'ROHAN A NETRAKAR', 14, '2026-03-16 09:09:54.60749+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (460, 'ROHAN A NETRAKAR', 14, '2026-03-16 09:13:58.781965+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (461, 'ROHAN A NETRAKAR', 14, '2026-03-16 09:14:14.65051+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (462, 'ROHAN A NETRAKAR', 14, '2026-03-16 09:14:30.644176+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (463, 'ROHAN A NETRAKAR', 14, '2026-03-16 09:14:46.492451+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (464, 'ROHAN A NETRAKAR', 14, '2026-03-16 09:15:05.303498+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (465, 'ROHAN A NETRAKAR', 14, '2026-03-16 09:17:16.806343+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (466, 'ROHAN A NETRAKAR', 14, '2026-03-16 09:17:33.045848+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (467, 'ROHAN A NETRAKAR', 14, '2026-03-16 09:17:48.708462+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (468, 'ROHAN A NETRAKAR', 14, '2026-03-16 09:18:04.688089+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (469, 'ROHAN A NETRAKAR', 14, '2026-03-16 09:18:20.669833+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (470, 'ROHAN A NETRAKAR', 13, '2026-03-16 09:18:41.761499+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (471, 'ROHAN A NETRAKAR', 14, '2026-03-16 09:19:09.519301+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (472, 'ROHAN A NETRAKAR', 14, '2026-03-16 09:19:25.422937+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (473, 'ROHAN A NETRAKAR', 14, '2026-03-16 09:19:41.334938+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (474, 'ROHAN A NETRAKAR', 9, '2026-03-16 09:31:14.000584+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (475, 'ROHAN A NETRAKAR', 9, '2026-03-16 09:31:30.143231+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (476, 'ROHAN A NETRAKAR', 9, '2026-03-16 09:31:46.57482+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (477, 'ROHAN A NETRAKAR', 9, '2026-03-16 09:32:02.459009+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (478, 'ROHAN A NETRAKAR', 9, '2026-03-16 09:32:18.189991+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (479, 'ROHAN A NETRAKAR', 9, '2026-03-16 09:32:33.993672+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (480, 'ROHAN A NETRAKAR', 9, '2026-03-16 09:32:49.781714+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (481, 'ROHAN A NETRAKAR', 9, '2026-03-16 09:33:05.548026+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (482, 'ROHAN A NETRAKAR', 9, '2026-03-16 09:33:21.280543+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (483, 'ROHAN A NETRAKAR', 9, '2026-03-16 09:33:36.986984+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (484, 'ROHAN A NETRAKAR', 9, '2026-03-16 09:33:52.731723+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (485, 'ROHAN A NETRAKAR', 9, '2026-03-16 09:34:08.471843+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (486, 'ROHAN A NETRAKAR', 9, '2026-03-16 09:34:24.708998+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (487, 'ROHAN A NETRAKAR', 9, '2026-03-16 09:34:40.640664+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (488, 'ROHAN A NETRAKAR', 9, '2026-03-16 09:34:56.360235+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (489, 'ROHAN A NETRAKAR', 9, '2026-03-16 09:35:12.076929+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (490, 'ROHAN A NETRAKAR', 9, '2026-03-16 09:35:27.857717+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (491, 'ROHAN A NETRAKAR', 9, '2026-03-16 09:35:43.751925+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (492, 'ROHAN A NETRAKAR', 9, '2026-03-16 09:35:59.520585+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (493, 'ROHAN A NETRAKAR', 9, '2026-03-16 09:36:15.269005+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (494, 'ROHAN A NETRAKAR', 9, '2026-03-16 09:36:31.585534+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (495, 'ROHAN A NETRAKAR', 9, '2026-03-16 09:36:47.288164+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (496, 'ROHAN A NETRAKAR', 9, '2026-03-16 09:37:42.285539+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (497, 'ROHAN A NETRAKAR', 14, '2026-03-16 09:42:18.272531+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (498, 'ROHAN A NETRAKAR', 14, '2026-03-16 09:43:37.511333+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (499, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:10:01.140822+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (500, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:10:16.927168+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (501, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:10:32.868728+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (502, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:10:48.579418+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (503, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:11:04.257717+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (504, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:11:20.002725+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (505, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:11:35.811159+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (506, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:11:51.542327+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (507, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:12:07.483049+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (508, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:12:23.624678+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (509, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:12:39.494728+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (510, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:12:55.182399+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (511, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:13:10.914725+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (512, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:13:26.638435+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (513, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:13:42.443383+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (514, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:14:09.922685+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (515, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:14:25.726479+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (516, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:15:01.259244+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (517, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:23:55.299133+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (518, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:24:11.536922+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (519, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:24:29.72799+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (520, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:24:45.525202+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (521, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:25:26.999722+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (522, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:25:42.812493+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (523, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:26:15.602325+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (524, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:26:31.54267+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (525, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:26:50.940377+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (526, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:27:07.068586+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (527, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:27:30.713244+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (528, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:27:46.47049+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (529, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:28:02.314165+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (530, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:28:18.089047+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (531, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:28:33.901204+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (532, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:28:49.661608+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (533, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:29:05.687947+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (534, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:35:41.598615+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (535, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:35:57.917434+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (536, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:36:13.975398+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (537, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:36:29.884717+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (538, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:36:45.637279+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (539, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:37:01.363462+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (540, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:37:17.037956+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (541, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:37:32.8246+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (542, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:37:48.564507+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (543, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:38:04.318154+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (544, 'ROHAN A NETRAKAR', 9, '2026-04-06 08:38:20.120978+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (545, 'ROHAN A NETRAKAR', 5, '2026-04-06 09:20:52.143495+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (546, 'ROHAN A NETRAKAR', 5, '2026-04-06 09:21:07.678748+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (547, 'ROHAN A NETRAKAR', 5, '2026-04-06 09:21:23.558941+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (548, 'ROHAN A NETRAKAR', 5, '2026-04-06 09:21:39.367717+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (549, 'ROHAN A NETRAKAR', 5, '2026-04-06 09:21:55.156873+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (550, 'ROHAN A NETRAKAR', 5, '2026-04-06 09:22:10.903244+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (551, 'ROHAN A NETRAKAR', 5, '2026-04-06 09:22:26.719919+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (552, 'ROHAN A NETRAKAR', 9, '2026-04-06 09:23:25.380144+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (553, 'ROHAN A NETRAKAR', 5, '2026-04-06 09:23:49.777722+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (554, 'ROHAN A NETRAKAR', 5, '2026-04-06 09:24:05.365426+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (555, 'ROHAN A NETRAKAR', 5, '2026-04-06 09:24:20.884623+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (556, 'ROHAN A NETRAKAR', 5, '2026-04-06 09:24:36.59975+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (557, 'ROHAN A NETRAKAR', 5, '2026-04-06 09:24:52.641379+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (558, 'ROHAN A NETRAKAR', 5, '2026-04-06 09:25:08.540239+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (559, 'ROHAN A NETRAKAR', 5, '2026-04-06 09:25:24.264678+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (560, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:27:39.283413+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (561, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:27:54.853795+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (562, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:28:10.786924+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (563, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:28:13.987071+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (564, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:28:29.75472+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (565, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:28:45.58979+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (566, 'SRUJANA', 12, '2026-04-06 09:28:51.803714+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (567, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:29:01.130409+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (568, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:29:16.716386+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (569, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:29:32.388689+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (570, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:30:07.359463+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (571, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:30:09.728726+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (572, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:30:25.212986+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (573, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:31:23.016833+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (574, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:39:02.15212+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (575, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:41:40.805738+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (576, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:44:59.390422+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (577, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:46:39.18766+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (578, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:46:54.934944+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (579, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:47:10.750121+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (580, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:47:26.532784+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (581, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:47:47.183235+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (582, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:48:03.061389+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (583, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:48:27.660721+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (584, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:48:58.531664+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (585, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:49:13.825849+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (586, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:49:29.455343+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (587, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:49:45.310628+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (588, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:50:01.152125+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (589, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:55:32.681442+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (590, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:56:21.364938+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (591, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:56:37.41028+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (592, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:56:53.832142+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (593, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:57:09.50604+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (594, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:57:25.32873+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (595, 'ROHAN A NETRAKAR', 12, '2026-04-06 09:57:41.095351+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (596, 'ROHAN A NETRAKAR', 14, '2026-04-06 09:58:45.017286+00');
INSERT INTO location_history (id, user_id, room_id, entered_at) OVERRIDING SYSTEM VALUE VALUES (597, 'ROHAN A NETRAKAR', 9, '2026-04-06 10:02:41.312017+00');

-- ============================================================
--  SECTION 3: FIX SEQUENCES (so next INSERT gets correct IDs)
-- ============================================================

SELECT setval('rooms_id_seq',            14);
SELECT setval('room_bssids_id_seq',      32);
SELECT setval('location_history_id_seq', 597);
SELECT setval('room_reservations_id_seq', 1, false);

-- ============================================================
--  DONE — Database fully restored.
-- ============================================================