INSERT INTO tools (tool_name, available_quantity)
VALUES
('Hammer', 10),
('Screwdriver', 5),
('Spanner', 2);
SELECT * FROM tools;
DO $$
DECLARE
    quantity_available INT;
BEGIN
    SELECT available_quantity
    INTO quantity_available
    FROM tools
    WHERE tool_id = 1;

    IF quantity_available = 0 THEN
        RAISE NOTICE 'Tool is unavailable';

    ELSIF quantity_available <= 3 THEN
        RAISE NOTICE 'Tool is low on stock';

    ELSE
        RAISE NOTICE 'Tool is readily available';
    END IF;
END $$;
DO $$
DECLARE
    reminder_number INT := 1;
BEGIN
    WHILE reminder_number <= 3 LOOP
        RAISE NOTICE 'Workshop safety reminder: %', reminder_number;
        reminder_number := reminder_number + 1;
    END LOOP;
END $$;
DO $$
BEGIN
    FOR inspection_number IN 1..3 LOOP
        RAISE NOTICE 'Tool inspection number: %', inspection_number;
    END LOOP;
END $$;
CREATE OR REPLACE PROCEDURE issue_tool(
    p_tool_id INT,
    p_student_number VARCHAR(20),
    p_quantity INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    current_quantity INT;
BEGIN

    SELECT available_quantity
    INTO current_quantity
    FROM tools
    WHERE tool_id = p_tool_id;

    IF p_quantity <= current_quantity THEN

        UPDATE tools
        SET available_quantity = available_quantity - p_quantity
        WHERE tool_id = p_tool_id;

        INSERT INTO tool_loans
            (tool_id, student_number, quantity, status)
        VALUES
            (p_tool_id, p_student_number, p_quantity, 'ISSUED');

        RAISE NOTICE 'Tool issued successfully.';

    ELSE

        RAISE NOTICE 'Not enough tools available.';

    END IF;
END;
$$;
CALL issue_tool(1, '202409001', 2);
CALL issue_tool(2, '202409002', 2);
CALL issue_tool(3, '202409003', 10);
SELECT * FROM tools;
SELECT * FROM tool_loans;
CREATE OR REPLACE PROCEDURE return_tool(
    p_loan_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    returned_tool_id INT;
    returned_quantity INT;
    current_status VARCHAR(20);
BEGIN

    SELECT tool_id, quantity, status
    INTO returned_tool_id, returned_quantity, current_status
    FROM tool_loans
    WHERE loan_id = p_loan_id;

    IF current_status = 'ISSUED' THEN

        UPDATE tools
        SET available_quantity = available_quantity + returned_quantity
        WHERE tool_id = returned_tool_id;

        UPDATE tool_loans
        SET status = 'RETURNED'
        WHERE loan_id = p_loan_id;

        RAISE NOTICE 'Tool returned successfully.';

    ELSE

        RAISE NOTICE 'This tool loan has already been returned.';

    END IF;
END;
$$;
CALL return_tool(1);
CALL return_tool(1);
SELECT * FROM tools;
SELECT * FROM tool_loans;
DO $$
DECLARE
    tool_record RECORD;

    tool_cursor CURSOR FOR
        SELECT tool_id, tool_name, available_quantity
        FROM tools
        WHERE available_quantity <= 3;

BEGIN

    OPEN tool_cursor;

    LOOP
        FETCH tool_cursor INTO tool_record;

        EXIT WHEN NOT FOUND;

        RAISE NOTICE 'Tool: %, Available quantity: %',
            tool_record.tool_name,
            tool_record.available_quantity;
    END LOOP;

    CLOSE tool_cursor;
END $$;
DO $$
BEGIN

    IF 0 <= 0 THEN
        RAISE EXCEPTION 'Invalid quantity: quantity must be greater than zero';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error handled: %', SQLERRM;
END $$;
SELECT * FROM tools;
SELECT * FROM tool_loans;