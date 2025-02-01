CREATE DATABASE IF NOT EXISTS day2;
USE day2;

CREATE TABLE IF NOT EXISTS input (
    lvl0 INT,
    lvl1 INT,
    lvl2 INT,
    lvl3 INT,
    lvl4 INT,
    lvl5 INT,
    lvl6 INT,
    lvl7 INT
);

CREATE TABLE IF NOT EXISTS lvl (
    id INT PRIMARY KEY AUTO_INCREMENT,
    val INT,
    next_lvl_id INT,
FOREIGN KEY (next_lvl_id) REFERENCES lvl(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS report (
    id INT PRIMARY KEY AUTO_INCREMENT,
    first_lvl_id INT,
    is_safe INT,
FOREIGN KEY (first_lvl_id) REFERENCES lvl(id) ON DELETE CASCADE,
CONSTRAINT boolean CHECK (is_safe IN (0, 1))
);

DELIMITER $$
CREATE FUNCTION is_report_safe(p_report_id INT) RETURNS INT
NOT DETERMINISTIC
BEGIN
DECLARE is_safe INT;
SET @is_safe = 1;
SET @prev_lvl_id = NULL;
SET @prev_lvl_val = NULL;
SET @current_lvl_id = NULL;
SET @current_lvl_val = NULL;
SET @delta_val = NULL;
SET @is_increasing = NULL;

SELECT id, val
INTO @prev_lvl_id, @prev_lvl_val
FROM lvl
WHERE id = (
    SELECT first_lvl_id
    FROM report
    WHERE report_id = p_report_id
);

safety: LOOP
    SELECT next_lvl_id
    INTO @current_lvl_id
    FROM lvl
    WHERE id = @prev_lvl_id;

    IF @current_lvl_id IS NULL THEN
        LEAVE safety;
    END IF;

    SELECT val
    INTO @current_lvl_val
    FROM lvl
    WHERE id = @current_lvl_id;

    SET @delta_val = @current_lvl_val - @prev_lvl_val;
    SET @delta_val_abs = ABS(@delta_abs);

    IF @is_increasing IS NULL THEN
        SET @is_increasing = @delta_val > 0;
    ELSE IF (@delta_val > 0) != @is_increasing THEN
        SET @is_safe = 0;
        LEAVE safety;
    ELSE IF @delta_val_abs < 1 OR @delta_val_abs > 3 THEN
        SET @is_safe = 0;
        LEAVE safety;
    END IF;

    SET @prev_lvl_id = @current_lvl_id;
    SET @prev_lvl_val = @current_lvl_val;
END LOOP;

RETURN is_safe;
END$$
DELIMITER ;

DROP DATABASE IF EXISTS day2;