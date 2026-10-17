INSERT INTO users (USER_ID, NAME, EMAIL, PASSWORD, PHONE, ROLE)
VALUES (user_seq.NEXTVAL, 'Admin User', 'admin@cowork.com', 'admin123', '01700000000', 'Admin');

INSERT INTO users (USER_ID, NAME, EMAIL, PASSWORD, PHONE, ROLE)
VALUES (user_seq.NEXTVAL, 'John Member', 'john@gmail.com', '1234', '01811111111', 'Member');

INSERT INTO spaces (SPACE_ID, TITLE, SPACE_TYPE, CAPACITY, HOURLY_RATE, LOCATION_FLOOR, DESCRIPTION)
VALUES (space_seq.NEXTVAL, 'Dedicated Desk A1', 'Desk', 1, 10.00, 'Floor 2', 'Dedicated workstation with dual monitors & ergonomic mesh chair');

INSERT INTO spaces (SPACE_ID, TITLE, SPACE_TYPE, CAPACITY, HOURLY_RATE, LOCATION_FLOOR, DESCRIPTION)
VALUES (space_seq.NEXTVAL, 'Flexi Hot Desk B04', 'Desk', 1, 8.00, 'Floor 2', 'Open-plan flexible desk with high-speed Wi-Fi and power outlets');

INSERT INTO spaces (SPACE_ID, TITLE, SPACE_TYPE, CAPACITY, HOURLY_RATE, LOCATION_FLOOR, DESCRIPTION)
VALUES (space_seq.NEXTVAL, 'Private Cabin C101', 'Cabin', 4, 35.00, 'Floor 3', 'Soundproof private team cabin with whiteboard and dedicated AC');

INSERT INTO spaces (SPACE_ID, TITLE, SPACE_TYPE, CAPACITY, HOURLY_RATE, LOCATION_FLOOR, DESCRIPTION)
VALUES (space_seq.NEXTVAL, 'Team Suite C105', 'Cabin', 8, 55.00, 'Floor 3', 'Executive corner suite with executive desks and presentation screen');

INSERT INTO spaces (SPACE_ID, TITLE, SPACE_TYPE, CAPACITY, HOURLY_RATE, LOCATION_FLOOR, DESCRIPTION)
VALUES (space_seq.NEXTVAL, 'Conference Room M01', 'Meeting Room', 12, 75.00, 'Floor 4', 'Full board room equipped with 4K projector, conference phone and glass board');

COMMIT;
