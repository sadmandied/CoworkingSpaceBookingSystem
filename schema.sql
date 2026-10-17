DROP TABLE payments CASCADE CONSTRAINTS;
DROP TABLE bookings CASCADE CONSTRAINTS;
DROP TABLE spaces CASCADE CONSTRAINTS;
DROP TABLE users CASCADE CONSTRAINTS;

DROP SEQUENCE user_seq;
DROP SEQUENCE space_seq;
DROP SEQUENCE booking_seq;
DROP SEQUENCE payment_seq;

CREATE SEQUENCE user_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE space_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE booking_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE payment_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE users (
    user_id NUMBER PRIMARY KEY,
    name VARCHAR2(100),
    email VARCHAR2(100),
    password VARCHAR2(100),
    phone VARCHAR2(20),
    role VARCHAR2(20)
);

CREATE TABLE spaces (
    space_id NUMBER PRIMARY KEY,
    title VARCHAR2(100),
    space_type VARCHAR2(50),
    capacity NUMBER,
    hourly_rate NUMBER,
    location_floor VARCHAR2(50),
    description VARCHAR2(200)
);

CREATE TABLE bookings (
    booking_id NUMBER PRIMARY KEY,
    user_id NUMBER,
    space_id NUMBER,
    booking_date VARCHAR2(20),
    start_time VARCHAR2(10),
    end_time VARCHAR2(10),
    hours NUMBER,
    total_amount NUMBER,
    status VARCHAR2(20)
);

CREATE TABLE payments (
    payment_id NUMBER PRIMARY KEY,
    booking_id NUMBER,
    payment_method VARCHAR2(50),
    amount NUMBER,
    status VARCHAR2(20)
);

INSERT INTO users VALUES (user_seq.NEXTVAL, 'Admin User', 'admin@cowork.com', 'admin123', '01700000000', 'Admin');
INSERT INTO users VALUES (user_seq.NEXTVAL, 'John Member', 'john@gmail.com', '1234', '01811111111', 'Member');

INSERT INTO spaces VALUES (space_seq.NEXTVAL, 'Dedicated Desk A1', 'Desk', 1, 10, 'Floor 2', 'Single desk with Wi-Fi and power outlet');
INSERT INTO spaces VALUES (space_seq.NEXTVAL, 'Flexi Hot Desk B04', 'Desk', 1, 8, 'Floor 2', 'Hot desk in open coworking space');
INSERT INTO spaces VALUES (space_seq.NEXTVAL, 'Private Cabin C101', 'Cabin', 4, 35, 'Floor 3', 'Soundproof private glass office cabin');
INSERT INTO spaces VALUES (space_seq.NEXTVAL, 'Team Suite C105', 'Cabin', 8, 55, 'Floor 3', 'Spacious private cabin for small teams');
INSERT INTO spaces VALUES (space_seq.NEXTVAL, 'Conference Room M01', 'Meeting Room', 12, 75, 'Floor 4', 'Conference room with 4K screen & whiteboard');

COMMIT;
