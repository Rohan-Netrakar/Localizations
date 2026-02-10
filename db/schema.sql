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
