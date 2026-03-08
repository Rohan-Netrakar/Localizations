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
