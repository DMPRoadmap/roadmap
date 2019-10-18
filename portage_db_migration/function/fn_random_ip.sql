DELIMITER //
DROP FUNCTION IF EXISTS random_ip;
//

CREATE FUNCTION random_ip()
    RETURNS VARCHAR(19)
    NO SQL
    BEGIN
        DECLARE v_ip VARCHAR(16) DEFAULT '';
        SET v_ip := CONCAT(TRUNCATE( RAND() * (255 - 1 + 1) + 1, 0 ), '.',
			TRUNCATE( RAND() * (255 - 1 + 1) + 1, 0 ), '.',
			TRUNCATE( RAND() * (255 - 1 + 1) + 1, 0 ), '.',
			TRUNCATE( RAND() * (255 - 1 + 1) + 1, 0 ));
        RETURN v_ip;
    END;
//
DELIMITER ;