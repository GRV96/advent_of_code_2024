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
    prev_lvl_id INT,
    next_lvl_id INT,
FOREIGN KEY (prev_lvl_id) REFERENCES lvl(id),
FOREIGN KEY (next_lvl_id) REFERENCES lvl(id)
);
TRUNCATE lvl;

CREATE TABLE IF NOT EXISTS report_lvl_chain (
    id INT PRIMARY KEY UNIQUE AUTO_INCREMENT,
    lvl_chain VARCHAR(200)
);
TRUNCATE report_lvl_chain;

CREATE TABLE IF NOT EXISTS report (
    id INT PRIMARY KEY UNIQUE AUTO_INCREMENT,
    first_lvl_id INT,
    nb_bad_levels INT DEFAULT -1,
FOREIGN KEY (first_lvl_id) REFERENCES lvl(id)
);
TRUNCATE report;

CREATE TABLE IF NOT EXISTS bad_level_steps (
    id INT PRIMARY KEY UNIQUE AUTO_INCREMENT,
    report_id INT,
    lvl_chain VARCHAR(200),
FOREIGN KEY (report_id) REFERENCES report(id)
);

DELIMITER $$
CREATE PROCEDURE display_reports_and_levels()
BEGIN
SELECT *
FROM report;

SELECT *
FROM lvl;
END$$

CREATE PROCEDURE display_bad_level_steps(IN p_report_id INT)
BEGIN
SELECT *
FROM bad_level_steps
WHERE report_id = p_report_id;
END$$

CREATE PROCEDURE display_unsafe_reports(IN p_safety_limit INT)
BEGIN
SELECT r.id, r.nb_bad_levels, c.lvl_chain
FROM report r
JOIN report_lvl_chain c
ON r.id = c.id
WHERE nb_bad_levels > p_safety_limit;
END$$

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

CREATE PROCEDURE set_prev_lvl_id(IN p_lvl_id INT, IN p_prev_lvl_id INT)
DETERMINISTIC
BEGIN
UPDATE lvl
SET prev_lvl_id = p_prev_lvl_id
WHERE id = p_lvl_id;
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
INSERT INTO lvl (val, prev_lvl_id) VALUES
(lvl_val, p_prev_lvl_id);
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

CREATE PROCEDURE set_report_first_lvl(IN p_report_id INT, IN p_first_lvl_id INT)
BEGIN
UPDATE report
SET first_lvl_id = p_first_lvl_id
WHERE id = p_report_id;
END$$

CREATE PROCEDURE get_lvl_data(IN p_lvl_id INT, OUT p_lvl_val INT, OUT p_next_lvl_id INT)
BEGIN
SELECT val, next_lvl_id
INTO p_lvl_val, p_next_lvl_id
FROM lvl
WHERE id = p_lvl_id;
END$$

CREATE PROCEDURE get_lvl_val(IN p_lvl_id INT, OUT p_lvl_val INT)
BEGIN
SELECT val
INTO p_lvl_val
FROM lvl
WHERE id = p_lvl_id;
END$$

CREATE PROCEDURE get_prev_lvl_id(IN p_lvl_id INT, OUT p_prev_lvl_id INT)
BEGIN
SELECT prev_lvl_id
INTO p_prev_lvl_id
FROM lvl
WHERE id = p_lvl_id;
END$$

CREATE PROCEDURE get_next_lvl_id(IN p_lvl_id INT, OUT p_next_lvl_id INT)
BEGIN
SELECT next_lvl_id
INTO p_next_lvl_id
FROM lvl
WHERE id = p_lvl_id;
END$$

CREATE FUNCTION get_report_with_first_lvl(p_first_lvl_id INT) RETURNS INT
READS SQL DATA
BEGIN
DECLARE rep_id INT;

SELECT id
INTO rep_id
FROM report
WHERE first_lvl_id = p_first_lvl_id;

RETURN rep_id;
END$$

CREATE PROCEDURE del_lvl(IN p_lvl_id INT)
BEGIN
DECLARE prev_lvl_id INT;
DECLARE next_lvl_id INT;
SET prev_lvl_id = NULL;
SET next_lvl_id = NULL;

CALL get_prev_lvl_id(p_lvl_id, prev_lvl_id);
CALL get_next_lvl_id(p_lvl_id, next_lvl_id);

CALL set_next_lvl_id(prev_lvl_id, next_lvl_id);
CALL set_prev_lvl_id(next_lvl_id, prev_lvl_id);

# To prevent error 1451
UPDATE lvl
SET prev_lvl_id = NULL, next_lvl_id = NULL
WHERE id = p_lvl_id;
CALL set_report_first_lvl(get_report_with_first_lvl(p_lvl_id), NULL);

DELETE
FROM lvl
WHERE id = p_lvl_id;
END$$

CREATE FUNCTION is_delta_safe(p_delta INT, p_expected_sign INT) RETURNS INT
NO SQL
BEGIN
DECLARE is_sign_correct INT;
DECLARE is_value_safe INT;
DECLARE abs_delta INT;

SET abs_delta = ABS(p_delta);
SET is_value_safe = abs_delta >= 1 AND abs_delta <= 3;
SET is_sign_correct = p_expected_sign IS NULL OR SIGN(p_delta) = p_expected_sign;

RETURN is_value_safe AND is_sign_correct;
END$$

CREATE FUNCTION make_lvl_chain_text(p_report_id INT) RETURNS VARCHAR(200)
READS SQL DATA
BEGIN
DECLARE current_lvl_id INT;
DECLARE current_lvl_val INT;
DECLARE next_lvl_id INT;
DECLARE next_lvl_val INT;
DECLARE delta INT;
DECLARE lvl_chain VARCHAR(200);
SET current_lvl_val = NULL;
SET next_lvl_id = NULL;
SET lvl_chain = "";

SELECT first_lvl_id
INTO current_lvl_id
FROM report
WHERE id = p_report_id;

lvl_chain_loop: LOOP
IF current_lvl_id IS NULL THEN
    LEAVE lvl_chain_loop;
END IF;

CALL get_lvl_data(current_lvl_id, current_lvl_val, next_lvl_id);

IF next_lvl_id IS NULL THEN
    SET delta = NULL;
ELSE
    CALL get_lvl_val(next_lvl_id, next_lvl_val);
    SET delta = next_lvl_val - current_lvl_val;
END IF;

SET lvl_chain = CONCAT(lvl_chain, " [id: ", current_lvl_id, " v: ", current_lvl_val, " d: ", IFNULL(delta, "-"), "]");

SET current_lvl_id = next_lvl_id;
END LOOP;

RETURN lvl_chain;
END$$

CREATE PROCEDURE remove_bad_levels(IN p_report_id INT)
BEGIN
DECLARE nb_bad_lvls INT;
DECLARE f_lvl_id INT;
DECLARE prev_lvl_id INT;
DECLARE current_lvl_id INT;
DECLARE current_lvl_val INT;
DECLARE next_lvl_id INT;
DECLARE next_lvl_val INT;
DECLARE delta_lvl_val INT;
DECLARE expected_sign INT;
DECLARE lvl_chain VARCHAR(200);
SET nb_bad_lvls = 0;
SET f_lvl_id = NULL;
SET prev_lvl_id = NULL;
SET current_lvl_id = NULL;
SET current_lvl_val = NULL;
SET next_lvl_id = NULL;
SET next_lvl_val = NULL;
SET delta_lvl_val = NULL;
SET expected_sign = NULL;
SET lvl_chain = NULL;

SELECT first_lvl_id
INTO f_lvl_id
FROM report
WHERE id = p_report_id;
SET current_lvl_id = f_lvl_id;

bad_lvl_loop: LOOP
CALL get_next_lvl_id(current_lvl_id, next_lvl_id);

IF next_lvl_id IS NULL THEN
    LEAVE bad_lvl_loop;
END IF;

CALL get_lvl_val(current_lvl_id, current_lvl_val);
CALL get_lvl_val(next_lvl_id, next_lvl_val);
SET delta_lvl_val = next_lvl_val - current_lvl_val;

IF is_delta_safe(delta_lvl_val, expected_sign) THEN
    SET prev_lvl_id = current_lvl_id;
    SET current_lvl_id = next_lvl_id;

    IF expected_sign IS NULL THEN
        SET expected_sign = sign(delta_lvl_val);
    END IF;
ELSE # Delete the bad level.
    CALL del_lvl(current_lvl_id);
    SET nb_bad_lvls = nb_bad_lvls + 1;

    IF current_lvl_id = f_lvl_id THEN
        SET current_lvl_id = next_lvl_id;
        SET f_lvl_id = current_lvl_id;
        SET prev_lvl_id = NULL;
        CALL set_report_first_lvl(p_report_id, f_lvl_id);
    ELSE
        SET current_lvl_id = prev_lvl_id;
        CALL get_prev_lvl_id(current_lvl_id, prev_lvl_id);
    END IF;
END IF;

SET lvl_chain = make_lvl_chain_text(p_report_id);
INSERT INTO bad_level_steps (report_id, lvl_chain) VALUES
(p_report_id, lvl_chain);
END LOOP;

UPDATE report
SET nb_bad_levels = nb_bad_lvls
WHERE id = p_report_id;

INSERT INTO report_lvl_chain (id, lvl_chain) VALUES
(p_report_id, lvl_chain);
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
LOAD DATA LOCAL INFILE "Day2Puzzle.txt"
INTO TABLE input
FIELDS TERMINATED BY " "
(lvl0, lvl1, lvl2, lvl3, lvl4, lvl5, lvl6, lvl7);

CALL make_all_reports();
CALL display_reports_and_levels();

CALL remove_all_bad_levels();
CALL display_reports_and_levels();

CALL display_bad_level_steps(623);
CALL display_unsafe_reports(1);

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