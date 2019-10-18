DELIMITER //
DROP FUNCTION IF EXISTS random_email;
//

CREATE FUNCTION random_email()
    RETURNS VARCHAR(19)
    NO SQL
    BEGIN
        DECLARE v_email VARCHAR(100) DEFAULT '';
        SET v_email := CONCAT(LOWER(str_random_lipsum(1, null, null)), '@', LOWER(str_random_lipsum(1, null, null)), '.ca');
        RETURN v_email;
    END;
//
DELIMITER ;