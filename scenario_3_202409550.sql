
INSERT INTO hostel_rooms (room_number, available_spaces)
VALUES
('Room 101', 4),
('Room 102', 2),
('Room 103', 1);

SELECT * FROM hostel_rooms;
DO $$
DECLARE
    spaces INT;
BEGIN
    SELECT available_spaces
    INTO spaces
    FROM hostel_rooms
    WHERE room_id = 1;

    IF spaces = 0 THEN
        RAISE NOTICE 'Room is full';

    ELSIF spaces = 1 THEN
        RAISE NOTICE 'Room has one space left';

    ELSE
        RAISE NOTICE 'Room has several spaces available';
    END IF;
END $$;

DO $$
DECLARE
    day_number INT := 1;
BEGIN
    WHILE day_number <= 3 LOOP
        RAISE NOTICE 'Hostel inspection day: %', day_number;
        day_number := day_number + 1;
    END LOOP;
END $$;
DO $$
BEGIN
    FOR check_number IN 1..3 LOOP
        RAISE NOTICE 'Room check number: %', check_number;
    END LOOP;
END $$;
CREATE OR REPLACE PROCEDURE allocate_room(
    p_student_number VARCHAR(20),
    p_room_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    current_spaces INT;
BEGIN

    SELECT available_spaces
    INTO current_spaces
    FROM hostel_rooms
    WHERE room_id = p_room_id;

    IF current_spaces > 0 THEN

        UPDATE hostel_rooms
        SET available_spaces = available_spaces - 1
        WHERE room_id = p_room_id;

        INSERT INTO allocations
            (student_number, room_id, status)
        VALUES
            (p_student_number, p_room_id, 'ALLOCATED');

        RAISE NOTICE 'Room allocated successfully.';

    ELSE

        RAISE NOTICE 'Room is full. Allocation not possible.';

    END IF;
END;
$$;
CALL allocate_room('202409001', 1);
CALL allocate_room('202409002', 2);
CALL allocate_room('202409003', 3);
CALL allocate_room('202409004', 3);
SELECT * FROM hostel_rooms;
SELECT * FROM allocations;
CREATE OR REPLACE PROCEDURE check_out(
    p_allocation_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    allocated_room_id INT;
    current_status VARCHAR(20);
BEGIN

    SELECT room_id, status
    INTO allocated_room_id, current_status
    FROM allocations
    WHERE allocation_id = p_allocation_id;

    IF current_status = 'ALLOCATED' THEN

        UPDATE hostel_rooms
        SET available_spaces = available_spaces + 1
        WHERE room_id = allocated_room_id;

        UPDATE allocations
        SET status = 'COMPLETED'
        WHERE allocation_id = p_allocation_id;

        RAISE NOTICE 'Student checked out successfully.';

    ELSE

        RAISE NOTICE 'This allocation has already been completed.';

    END IF;
END;
$$;
CALL check_out(1);
CALL check_out(1);
SELECT * FROM hostel_rooms;
SELECT * FROM allocations;
DO $$
DECLARE
    room_record RECORD;

    room_cursor CURSOR FOR
        SELECT room_id, room_number, available_spaces
        FROM hostel_rooms
        WHERE available_spaces <= 1;

BEGIN

    OPEN room_cursor;

    LOOP
        FETCH room_cursor INTO room_record;

        EXIT WHEN NOT FOUND;

        RAISE NOTICE 'Room: %, Available spaces: %',
            room_record.room_number,
            room_record.available_spaces;
    END LOOP;

    CLOSE room_cursor;
END $$;
DO $$
BEGIN

    IF '' = '' THEN
        RAISE EXCEPTION 'Invalid input: student number cannot be blank';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error handled: %', SQLERRM;
END $$;
SELECT * FROM hostel_rooms;
SELECT * FROM allocations;
