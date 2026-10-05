DO $$
BEGIN
    FOR shelf_number IN 1..3 LOOP
        RAISE NOTICE 'Library shelf number: %', shelf_number;
    END LOOP;
END $$;

CREATE OR REPLACE PROCEDURE borrow_book(
    p_book_id INT,
    p_student_number VARCHAR(20),
    p_quantity INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    current_copies INT;
BEGIN
    SELECT available_copies
    INTO current_copies
    FROM books
    WHERE book_id = p_book_id;

    IF p_quantity <= current_copies THEN

        UPDATE books
        SET available_copies = available_copies - p_quantity
        WHERE book_id = p_book_id;

        INSERT INTO book_loans
            (book_id, student_number, quantity, loan_status)
        VALUES
            (p_book_id, p_student_number, p_quantity, 'BORROWED');

        RAISE NOTICE 'Book borrowed successfully.';

    ELSE

        RAISE NOTICE 'Not enough copies available.';

    END IF;
END;
$$;

CALL borrow_book(1, '20240001', 2);

CALL borrow_book(2, '20240002', 2);

CALL borrow_book(3, '20240003', 10);

SELECT * FROM books;
SELECT * FROM book_loans;

CREATE OR REPLACE PROCEDURE return_book(
    p_loan_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    loan_book_id INT;
    loan_quantity INT;
    current_status VARCHAR(20);
BEGIN

    SELECT book_id, quantity, loan_status
    INTO loan_book_id, loan_quantity, current_status
    FROM book_loans
    WHERE loan_id = p_loan_id;

    IF current_status = 'BORROWED' THEN

        UPDATE books
        SET available_copies = available_copies + loan_quantity
        WHERE book_id = loan_book_id;

        UPDATE book_loans
        SET loan_status = 'RETURNED'
        WHERE loan_id = p_loan_id;

        RAISE NOTICE 'Book returned successfully.';

    ELSE

        RAISE NOTICE 'Loan has already been returned.';

    END IF;
END;
$$;

CALL return_book(1);
CALL return_book(1);
SELECT * FROM books;
SELECT * FROM book_loans;

DO $$
DECLARE
    book_record RECORD;

    book_cursor CURSOR FOR
        SELECT book_id, title, available_copies
        FROM books
        WHERE available_copies <= 3;

BEGIN

    OPEN book_cursor;

    LOOP
        FETCH book_cursor INTO book_record;

        EXIT WHEN NOT FOUND;

        RAISE NOTICE 'Book: %, Copies remaining: %',
            book_record.title,
            book_record.available_copies;
    END LOOP;

    CLOSE book_cursor;
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

SELECT * FROM books;
SELECT * FROM book_loans;
