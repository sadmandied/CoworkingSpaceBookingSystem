CREATE TABLE users (
    user_id NUMBER PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    email VARCHAR2(100) NOT NULL UNIQUE,
    password VARCHAR2(100) NOT NULL,
    phone VARCHAR2(20),
    role VARCHAR2(20) DEFAULT 'Member' CHECK (role IN ('Member', 'Admin'))
);

CREATE TABLE spaces (
    space_id NUMBER PRIMARY KEY,
    title VARCHAR2(100) NOT NULL,
    space_type VARCHAR2(50) NOT NULL,
    capacity NUMBER DEFAULT 1,
    hourly_rate NUMBER(10, 2) NOT NULL,
    location_floor VARCHAR2(50),
    description VARCHAR2(200)
);

CREATE TABLE bookings (
    booking_id NUMBER PRIMARY KEY,
    user_id NUMBER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    space_id NUMBER NOT NULL REFERENCES spaces(space_id) ON DELETE CASCADE,
    booking_date VARCHAR2(20) NOT NULL,
    start_time VARCHAR2(10) NOT NULL,
    end_time VARCHAR2(10) NOT NULL,
    hours NUMBER NOT NULL,
    total_amount NUMBER(10, 2) NOT NULL,
    status VARCHAR2(20) DEFAULT 'CONFIRMED' CHECK (status IN ('CONFIRMED', 'CANCELLED'))
);

CREATE TABLE payments (
    payment_id NUMBER PRIMARY KEY,
    booking_id NUMBER NOT NULL REFERENCES bookings(booking_id) ON DELETE CASCADE,
    payment_method VARCHAR2(50) NOT NULL,
    amount NUMBER(10, 2) NOT NULL,
    status VARCHAR2(20) DEFAULT 'Paid' CHECK (status IN ('Paid', 'Refunded'))
);

CREATE SEQUENCE user_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE space_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE booking_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE payment_seq START WITH 1 INCREMENT BY 1;
