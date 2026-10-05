INSERT INTO events (event_name, available_seats)
VALUES
('ICT Career Fair', 20),
('Computer Science Seminar', 10),
('Programming Workshop', 5);
SELECT * FROM events;
DO $$
DECLARE
    seats INT;
BEGIN
    SELECT available_seats
    INTO seats
    FROM events
    WHERE event_id = 1;

    IF seats = 0 THEN
        RAISE NOTICE 'Event is full';

    ELSIF seats <= 5 THEN
        RAISE NOTICE 'Event is nearly full';

    ELSE
        RAISE NOTICE 'Event has plenty of seats';
    END IF;
END $$;
DO $$
DECLARE
    reminder_day INT := 1;
BEGIN
    WHILE reminder_day <= 3 LOOP
        RAISE NOTICE 'Booking reminder day: %', reminder_day;
        reminder_day := reminder_day + 1;
    END LOOP;
END $$;
DO $$
BEGIN
    FOR check_number IN 1..3 LOOP
        RAISE NOTICE 'Entrance check number: %', check_number;
    END LOOP;
END $$;
CREATE OR REPLACE PROCEDURE book_seats(
    p_event_id INT,
    p_student_number VARCHAR(20),
    p_number_of_seats INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    current_seats INT;
BEGIN

    SELECT available_seats
    INTO current_seats
    FROM events
    WHERE event_id = p_event_id;

    IF p_number_of_seats <= current_seats THEN

        UPDATE events
        SET available_seats = available_seats - p_number_of_seats
        WHERE event_id = p_event_id;

        INSERT INTO bookings
            (event_id, student_number, number_of_seats, status)
        VALUES
            (p_event_id, p_student_number, p_number_of_seats, 'BOOKED');

        RAISE NOTICE 'Seats booked successfully.';

    ELSE

        RAISE NOTICE 'Not enough seats available.';

    END IF;
END;
$$;
CALL book_seats(1, '202409001', 3);
CALL book_seats(2, '202409002', 4);
CALL book_seats(3, '202409003', 10);
SELECT * FROM events;
SELECT * FROM bookings;
CREATE OR REPLACE PROCEDURE cancel_booking(
    p_booking_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    booked_event_id INT;
    booked_seats INT;
    current_status VARCHAR(20);
BEGIN

    SELECT event_id, number_of_seats, status
    INTO booked_event_id, booked_seats, current_status
    FROM bookings
    WHERE booking_id = p_booking_id;

    IF current_status = 'BOOKED' THEN

        UPDATE events
        SET available_seats = available_seats + booked_seats
        WHERE event_id = booked_event_id;

        UPDATE bookings
        SET status = 'CANCELLED'
        WHERE booking_id = p_booking_id;

        RAISE NOTICE 'Booking cancelled successfully.';

    ELSE

        RAISE NOTICE 'This booking has already been cancelled.';

    END IF;
END;
$$;
CALL cancel_booking(1);
CALL cancel_booking(1);
SELECT * FROM events;
DO $$
DECLARE
    event_record RECORD;

    event_cursor CURSOR FOR
        SELECT event_id, event_name, available_seats
        FROM events
        WHERE available_seats <= 5;

BEGIN

    OPEN event_cursor;

    LOOP
        FETCH event_cursor INTO event_record;

        EXIT WHEN NOT FOUND;

        RAISE NOTICE 'Event: %, Available seats: %',
            event_record.event_name,
            event_record.available_seats;
    END LOOP;

    CLOSE event_cursor;
END $$;
DO $$
BEGIN

    IF 0 <= 0 THEN
        RAISE EXCEPTION 'Invalid number of seats: must be greater than zero';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error handled: %', SQLERRM;
END $$;
SELECT * FROM events;
SELECT * FROM bookings;