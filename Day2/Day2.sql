CREATE DATABASE IF NOT EXISTS day2;
USE day2;

CREATE TABLE IF NOT EXISTS input (
    id INT PRIMARY KEY UNIQUE AUTO_INCREMENT,
    lvl0 INT,
    lvl1 INT,
    lvl2 INT,
    lvl3 INT,
    lvl4 INT,
    lvl5 INT,
    lvl6 INT,
    lvl7 INT
);
TRUNCATE input;

CREATE TABLE IF NOT EXISTS lvl (
    id INT PRIMARY KEY UNIQUE AUTO_INCREMENT,
    val INT,
    next_lvl_id INT,
FOREIGN KEY (next_lvl_id) REFERENCES lvl(id)
);
TRUNCATE lvl;

CREATE TABLE IF NOT EXISTS report (
    id INT PRIMARY KEY UNIQUE,
    first_lvl_id INT,
    nb_bad_levels INT DEFAULT -1,
FOREIGN KEY (first_lvl_id) REFERENCES lvl(id)
);
TRUNCATE report;

DELIMITER $$
CREATE FUNCTION get_last_lvl_id() RETURNS INT
NOT DETERMINISTIC
READS SQL DATA
BEGIN
DECLARE last_id INT;

SELECT id
INTO last_id
FROM lvl
ORDER BY id DESC
LIMIT 1;

RETURN last_id;
END$$

CREATE PROCEDURE set_next_lvl_id(IN p_lvl_id INT, IN p_next_lvl_id INT)
DETERMINISTIC
BEGIN
UPDATE lvl
SET next_lvl_id = p_next_lvl_id
WHERE id = p_lvl_id;
END$$

CREATE PROCEDURE make_lvl(IN lvl_val INT, IN p_prev_lvl_id INT, OUT p_lvl_id INT)
BEGIN
INSERT INTO lvl (val) VALUES
(lvl_val);
SET p_lvl_id = get_last_lvl_id();

IF p_prev_lvl_id IS NOT NULL THEN
    CALL set_next_lvl_id(p_prev_lvl_id, p_lvl_id);
END IF;
END$$

CREATE PROCEDURE make_report(IN p_input_id INT)
BEGIN
DECLARE first_lvl_id INT;
DECLARE prev_lvl_id INT;
DECLARE lvl_val INT;
DECLARE current_lvl_id INT;
SET first_lvl_id = NULL;
SET prev_lvl_id = NULL;
SET lvl_val = NULL;
SET current_lvl_id = NULL;

SELECT lvl0
INTO lvl_val
FROM input
WHERE id = p_input_id;

IF lvl_val IS NOT NULL THEN
    CALL make_lvl(lvl_val, prev_lvl_id, current_lvl_id);
    SET prev_lvl_id = current_lvl_id;

    IF first_lvl_id IS NULL THEN
        SET first_lvl_id = current_lvl_id;
    END IF;
END IF;

SELECT lvl1
INTO lvl_val
FROM input
WHERE id = p_input_id;

IF lvl_val IS NOT NULL THEN
    CALL make_lvl(lvl_val, prev_lvl_id, current_lvl_id);
    SET prev_lvl_id = current_lvl_id;

    IF first_lvl_id IS NULL THEN
        SET first_lvl_id = current_lvl_id;
    END IF;
END IF;

SELECT lvl2
INTO lvl_val
FROM input
WHERE id = p_input_id;

IF lvl_val IS NOT NULL THEN
    CALL make_lvl(lvl_val, prev_lvl_id, current_lvl_id);
    SET prev_lvl_id = current_lvl_id;

    IF first_lvl_id IS NULL THEN
        SET first_lvl_id = current_lvl_id;
    END IF;
END IF;

SELECT lvl3
INTO lvl_val
FROM input
WHERE id = p_input_id;

IF lvl_val IS NOT NULL THEN
    CALL make_lvl(lvl_val, prev_lvl_id, current_lvl_id);
    SET prev_lvl_id = current_lvl_id;

    IF first_lvl_id IS NULL THEN
        SET first_lvl_id = current_lvl_id;
    END IF;
END IF;

SELECT lvl4
INTO lvl_val
FROM input
WHERE id = p_input_id;

IF lvl_val IS NOT NULL THEN
    CALL make_lvl(lvl_val, prev_lvl_id, current_lvl_id);
    SET prev_lvl_id = current_lvl_id;

    IF first_lvl_id IS NULL THEN
        SET first_lvl_id = current_lvl_id;
    END IF;
END IF;

SELECT lvl5
INTO lvl_val
FROM input
WHERE id = p_input_id;

IF lvl_val IS NOT NULL THEN
    CALL make_lvl(lvl_val, prev_lvl_id, current_lvl_id);
    SET prev_lvl_id = current_lvl_id;

    IF first_lvl_id IS NULL THEN
        SET first_lvl_id = current_lvl_id;
    END IF;
END IF;

SELECT lvl6
INTO lvl_val
FROM input
WHERE id = p_input_id;

IF lvl_val IS NOT NULL THEN
    CALL make_lvl(lvl_val, prev_lvl_id, current_lvl_id);
    SET prev_lvl_id = current_lvl_id;

    IF first_lvl_id IS NULL THEN
        SET first_lvl_id = current_lvl_id;
    END IF;
END IF;

SELECT lvl7
INTO lvl_val
FROM input
WHERE id = p_input_id;

IF lvl_val IS NOT NULL THEN
    CALL make_lvl(lvl_val, prev_lvl_id, current_lvl_id);
    SET prev_lvl_id = current_lvl_id;

    IF first_lvl_id IS NULL THEN
        SET first_lvl_id = current_lvl_id;
    END IF;
END IF;

INSERT INTO report (id, first_lvl_id) VALUES
(p_input_id, first_lvl_id);
END$$

CREATE PROCEDURE make_all_reports()
BEGIN
DECLARE lvl_id INT;
DECLARE done INT DEFAULT FALSE;
DECLARE in_id_cur CURSOR FOR
    SELECT id
    FROM input
    WHERE id IS NOT NULL;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN in_id_cur;
in_loop: LOOP
    FETCH NEXT FROM in_id_cur INTO lvl_id;

    IF done THEN
        LEAVE in_loop;
    END IF;

    CALL make_report(lvl_id);
END LOOP;
CLOSE in_id_cur;
END$$

CREATE PROCEDURE get_lvl_data(IN p_lvl_id INT, OUT p_lvl_val INT, OUT p_next_lvl_id INT)
BEGIN
SELECT val, next_lvl_id
INTO p_lvl_val, p_next_lvl_id
FROM lvl
WHERE id = p_lvl_id;
END$$

CREATE PROCEDURE del_lvl(IN p_lvl_id INT)
BEGIN
# Normally, the referrencing record must be deleted before the referrenced record.
SET FOREIGN_KEY_CHECKS=0;
DELETE
FROM lvl
WHERE id = p_lvl_id;
SET FOREIGN_KEY_CHECKS=1;
END$$

CREATE FUNCTION is_delta_safe(p_delta INT, p_expected_sign INT) RETURNS INT
NO SQL
BEGIN
DECLARE is_sign_correct INT;
DECLARE is_value_safe INT;
DECLARE delta_abs INT;

SET delta_abs = ABS(p_delta);
SET is_value_safe = delta_abs >= 1 AND delta_abs <= 3;
SET is_sign_correct = p_expected_sign IS NULL OR SIGN(p_delta) = p_expected_sign;

RETURN is_value_safe AND is_sign_correct;
END$$

CREATE PROCEDURE remove_bad_levels(IN p_report_id INT)
BEGIN
DECLARE nb_bad_lvls INT;
DECLARE prev_lvl_id INT;
DECLARE prev_lvl_val INT;
DECLARE current_lvl_id INT;
DECLARE current_lvl_val INT;
DECLARE next_lvl_id INT;
DECLARE delta_lvl_val INT;
DECLARE expected_sign INT;
SET nb_bad_lvls = 0;
SET prev_lvl_id = NULL;
SET prev_lvl_val = NULL;
SET current_lvl_id = NULL;
SET current_lvl_val = NULL;
SET next_lvl_id = NULL;
SET delta_lvl_val = NULL;
SET expected_sign = NULL;

SELECT first_lvl_id
INTO prev_lvl_id
FROM report
WHERE id = p_report_id;

CALL get_lvl_data(prev_lvl_id, prev_lvl_val, current_lvl_id);

bad_lvl_loop: LOOP
IF current_lvl_id IS NULL THEN
    LEAVE bad_lvl_loop;
END IF;

CALL get_lvl_data(current_lvl_id, current_lvl_val, next_lvl_id);
SET delta_lvl_val = current_lvl_val - prev_lvl_val;

IF is_delta_safe(delta_lvl_val, expected_sign) THEN
    SET prev_lvl_id = current_lvl_id;
    SET prev_lvl_val = current_lvl_val;

    IF expected_sign IS NULL THEN
        SET expected_sign = sign(delta_lvl_val);
    END IF;
ELSE # Delete the bad level.
    CALL set_next_lvl_id(prev_lvl_id, next_lvl_id);
    CALL del_lvl(current_lvl_id);
    SET nb_bad_lvls = nb_bad_lvls + 1;
END IF;

SET current_lvl_id = next_lvl_id;
END LOOP;

UPDATE report
SET nb_bad_levels = nb_bad_lvls
WHERE id = p_report_id;
END$$

CREATE PROCEDURE remove_all_bad_levels()
BEGIN
DECLARE report_id INT;
DECLARE done INT DEFAULT FALSE;
DECLARE report_id_cur CURSOR FOR
    SELECT id
    FROM report
    WHERE id IS NOT NULL;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN report_id_cur;
report_loop: LOOP
    FETCH NEXT FROM report_id_cur INTO report_id;

    IF done THEN
        LEAVE report_loop;
    END IF;

    CALL remove_bad_levels(report_id);
END LOOP;
CLOSE report_id_cur;
END$$
DELIMITER ;

-- Absolute path required
LOAD DATA LOCAL INFILE "Day2Sample.txt"
INTO TABLE input
FIELDS TERMINATED BY " "
(lvl0, lvl1, lvl2, lvl3, lvl4, lvl5, lvl6, lvl7);

CALL make_all_reports();
CALL remove_all_bad_levels();

SET @puzzle1_answer = -1;
SELECT COUNT(*)
INTO @puzzle1_answer
FROM report
WHERE nb_bad_levels = 0;

SET @puzzle2_answer = -1;
SELECT COUNT(*)
INTO @puzzle2_answer
FROM report
WHERE nb_bad_levels <= 1;

SELECT @puzzle1_answer, @puzzle2_answer;

DROP DATABASE IF EXISTS day2;