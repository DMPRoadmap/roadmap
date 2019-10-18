DELIMITER //
DROP FUNCTION IF EXISTS random_orcid;
//

CREATE FUNCTION random_orcid()
    RETURNS VARCHAR(19)
    NO SQL
    BEGIN
        DECLARE v_orcid VARCHAR(19) DEFAULT '';
        SET v_orcid := CONCAT(LPAD(FLOOR(RAND() * 10000), 4, '0')
            , '-', LPAD(FLOOR(RAND() * 10000), 4, '0')
            , '-', LPAD(FLOOR(RAND() * 10000), 4, '0')
            , '-', LPAD(FLOOR(RAND() * 10000), 4, '0'));
        RETURN v_orcid;
    END;
//
DELIMITER ;