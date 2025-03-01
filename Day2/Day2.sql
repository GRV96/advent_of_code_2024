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

CREATE TABLE IF NOT EXISTS levels (
    id INT PRIMARY KEY UNIQUE AUTO_INCREMENT,
    val INT,
    prev_lvl_id INT,
    next_lvl_id INT,
FOREIGN KEY (prev_lvl_id) REFERENCES levels(id),
FOREIGN KEY (next_lvl_id) REFERENCES levels(id)
);

DELIMITER $$
CREATE PROCEDURE get_lvl_data(IN in_lvl_id INT, OUT out_lvl_val INT, OUT out_next_lvl_id INT)
BEGIN
SELECT val, next_lvl_id
INTO out_lvl_val, out_next_lvl_id
FROM levels
WHERE id = in_lvl_id;
END$$

CREATE FUNCTION levels_get_val(p_lvl_id INT) RETURNS INT
READS SQL DATA
BEGIN
DECLARE l_val INT;

SELECT val
INTO l_val
FROM levels
WHERE id = p_lvl_id;

RETURN l_val;
END$$

CREATE FUNCTION levels_get_prev_id(p_lvl_id INT) RETURNS INT
READS SQL DATA
BEGIN
DECLARE l_prev_lvl_id INT;

SELECT prev_lvl_id
INTO l_prev_lvl_id
FROM levels
WHERE id = p_lvl_id;

RETURN l_prev_lvl_id;
END$$

CREATE PROCEDURE levels_set_prev_id(IN in_lvl_id INT, IN in_prev_lvl_id INT)
BEGIN
UPDATE levels
SET prev_lvl_id = in_prev_lvl_id
WHERE id = in_lvl_id;
END$$

CREATE FUNCTION levels_get_next_id(p_lvl_id INT) RETURNS INT
READS SQL DATA
BEGIN
DECLARE l_next_lvl_id INT;

SELECT next_lvl_id
INTO l_next_lvl_id
FROM levels
WHERE id = p_lvl_id;

RETURN l_next_lvl_id;
END$$

CREATE PROCEDURE levels_set_next_id(IN in_lvl_id INT, IN in_next_lvl_id INT)
BEGIN
UPDATE levels
SET next_lvl_id = in_next_lvl_id
WHERE id = in_lvl_id;
END$$

CREATE FUNCTION get_last_lvl_id() RETURNS INT
READS SQL DATA
BEGIN
DECLARE l_last_id INT;

SELECT id
INTO l_last_id
FROM levels
ORDER BY id DESC
LIMIT 1;

RETURN l_last_id;
END$$

CREATE PROCEDURE make_level(IN in_lvl_val INT, IN in_prev_lvl_id INT, OUT out_lvl_id INT)
BEGIN
INSERT INTO levels (val, prev_lvl_id) VALUES
(in_lvl_val, in_prev_lvl_id);
SET out_lvl_id = get_last_lvl_id();

IF in_prev_lvl_id IS NOT NULL THEN
    CALL levels_set_next_id(in_prev_lvl_id, out_lvl_id);
END IF;
END$$

CREATE PROCEDURE delete_level(IN in_lvl_id INT)
BEGIN
DECLARE l_prev_lvl_id INT;
DECLARE l_next_lvl_id INT;
SET l_prev_lvl_id = levels_get_prev_id(in_lvl_id);
SET l_next_lvl_id = levels_get_next_id(in_lvl_id);

CALL levels_set_next_id(l_prev_lvl_id, l_next_lvl_id);
CALL levels_set_prev_id(l_next_lvl_id, l_prev_lvl_id);

# To prevent error 1451
UPDATE levels
SET prev_lvl_id = NULL, next_lvl_id = NULL
WHERE id = in_lvl_id;
CALL reports_set_first_lvl_id(get_report_with_first_lvl_id(in_lvl_id), NULL);

DELETE
FROM levels
WHERE id = in_lvl_id;
END$$

CREATE FUNCTION is_delta_safe(in_delta INT, in_expected_sign INT) RETURNS INT
NO SQL
BEGIN
DECLARE l_is_sign_correct INT;
DECLARE l_is_value_safe INT;
DECLARE l_abs_delta INT;

SET l_abs_delta = ABS(in_delta);
SET l_is_value_safe = l_abs_delta >= 1 AND l_abs_delta <= 3;
SET l_is_sign_correct =
    in_expected_sign IS NULL
    OR SIGN(in_delta) = in_expected_sign;

RETURN l_is_value_safe AND l_is_sign_correct;
END$$
DELIMITER ;

CREATE TABLE IF NOT EXISTS reports (
    id INT PRIMARY KEY UNIQUE AUTO_INCREMENT,
    first_lvl_id INT,
    nb_bad_levels INT DEFAULT -1,
FOREIGN KEY (first_lvl_id) REFERENCES levels(id)
);

DELIMITER $$
CREATE FUNCTION reports_get_first_lvl_id(p_report_id INT) RETURNS INT
READS SQL DATA
BEGIN
DECLARE l_first_lvl_id INT;

SELECT first_lvl_id
INTO l_first_lvl_id
FROM reports
WHERE id = p_report_id;

RETURN l_first_lvl_id;
END$$

CREATE PROCEDURE reports_set_first_lvl_id(IN in_report_id INT, IN in_first_lvl_id INT)
BEGIN
UPDATE reports
SET first_lvl_id = in_first_lvl_id
WHERE id = in_report_id;
END$$

CREATE FUNCTION get_report_with_first_lvl_id(p_first_lvl_id INT) RETURNS INT
READS SQL DATA
BEGIN
DECLARE l_rep_id INT;

SELECT id
INTO l_rep_id
FROM reports
WHERE first_lvl_id = p_first_lvl_id;

RETURN l_rep_id;
END$$

CREATE PROCEDURE display_reports_and_levels()
BEGIN
SELECT *
FROM reports;

SELECT *
FROM levels;
END$$
DELIMITER ;

CREATE TABLE IF NOT EXISTS report_lvl_chains (
    id INT PRIMARY KEY UNIQUE AUTO_INCREMENT,
    lvl_chain VARCHAR(200),
FOREIGN KEY (id) REFERENCES reports(id)
);

CREATE VIEW v_reports_and_lvl_chains AS
SELECT r.id, r.nb_bad_levels, r.first_lvl_id, c.lvl_chain
FROM reports r
JOIN report_lvl_chains c
ON r.id = c.id;

DELIMITER $$
CREATE PROCEDURE display_safe_reports(IN in_safety_threshold INT)
BEGIN
SELECT *
FROM v_reports_and_lvl_chains
WHERE nb_bad_levels <= in_safety_threshold;
END$$

CREATE PROCEDURE display_unsafe_reports(IN in_safety_threshold INT)
BEGIN
SELECT *
FROM v_reports_and_lvl_chains
WHERE nb_bad_levels > in_safety_threshold;
END$$
DELIMITER ;

CREATE TABLE IF NOT EXISTS bad_level_steps (
    id INT PRIMARY KEY UNIQUE AUTO_INCREMENT,
    report_id INT,
    current_lvl_id INT,
    expected_sign INT,
    lvl_chain VARCHAR(200),
FOREIGN KEY (report_id) REFERENCES reports(id)
);

DELIMITER $$
CREATE FUNCTION make_lvl_chain_text(p_report_id INT) RETURNS VARCHAR(200)
READS SQL DATA
BEGIN
DECLARE l_current_lvl_id INT;
DECLARE l_current_lvl_val INT;
DECLARE l_next_lvl_id INT;
DECLARE l_next_lvl_val INT;
DECLARE l_delta INT;
DECLARE l_lvl_chain VARCHAR(200);
SET l_current_lvl_id = reports_get_first_lvl_id(p_report_id);
SET l_current_lvl_val = NULL;
SET l_next_lvl_id = NULL;
SET l_lvl_chain = CONCAT("first_lvl: ", l_current_lvl_id);

lvl_chain_loop: LOOP
IF l_current_lvl_id IS NULL THEN
    LEAVE lvl_chain_loop;
END IF;

CALL get_lvl_data(l_current_lvl_id, l_current_lvl_val, l_next_lvl_id);

IF l_next_lvl_id IS NULL THEN
    SET l_delta = NULL;
ELSE
    SET l_next_lvl_val = levels_get_val(l_next_lvl_id);
    SET l_delta = l_next_lvl_val - l_current_lvl_val;
END IF;

SET l_lvl_chain = CONCAT(
    l_lvl_chain,
    " [id: ", l_current_lvl_id,
    " v: ", l_current_lvl_val,
    " d: ", IFNULL(l_delta, "-"), "]");

SET l_current_lvl_id = l_next_lvl_id;
END LOOP;

RETURN l_lvl_chain;
END$$

CREATE PROCEDURE make_bad_level_step(
    IN in_report_id INT,
    IN in_current_lvl_id INT,
    IN in_expected_sign INT,
    IN in_lvl_chain VARCHAR(200))
BEGIN
INSERT INTO bad_level_steps
    (report_id, current_lvl_id, expected_sign, lvl_chain) VALUES
(in_report_id, in_current_lvl_id, in_expected_sign, in_lvl_chain);
END $$

CREATE PROCEDURE display_bad_level_steps(IN in_report_id INT)
BEGIN
SELECT *
FROM bad_level_steps
WHERE report_id = in_report_id;
END$$
DELIMITER ;

DELIMITER $$
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
    CALL make_level(lvl_val, prev_lvl_id, current_lvl_id);
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
    CALL make_level(lvl_val, prev_lvl_id, current_lvl_id);
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
    CALL make_level(lvl_val, prev_lvl_id, current_lvl_id);
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
    CALL make_level(lvl_val, prev_lvl_id, current_lvl_id);
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
    CALL make_level(lvl_val, prev_lvl_id, current_lvl_id);
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
    CALL make_level(lvl_val, prev_lvl_id, current_lvl_id);
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
    CALL make_level(lvl_val, prev_lvl_id, current_lvl_id);
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
    CALL make_level(lvl_val, prev_lvl_id, current_lvl_id);
    SET prev_lvl_id = current_lvl_id;

    IF first_lvl_id IS NULL THEN
        SET first_lvl_id = current_lvl_id;
    END IF;
END IF;

INSERT INTO reports (id, first_lvl_id) VALUES
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

SET f_lvl_id = reports_get_first_lvl_id(p_report_id);
SET current_lvl_id = f_lvl_id;

bad_lvl_loop: LOOP
IF current_lvl_id = f_lvl_id THEN
    SET expected_sign = NULL;
END IF;

SET lvl_chain = make_lvl_chain_text(p_report_id);
CALL make_bad_level_step(
    p_report_id, current_lvl_id, expected_sign, lvl_chain);

SET next_lvl_id = levels_get_next_id(current_lvl_id);

IF next_lvl_id IS NULL THEN
    LEAVE bad_lvl_loop;
END IF;

SET current_lvl_val = levels_get_val(current_lvl_id);
SET next_lvl_val = levels_get_val(next_lvl_id);
SET delta_lvl_val = next_lvl_val - current_lvl_val;

IF is_delta_safe(delta_lvl_val, expected_sign) THEN
    SET prev_lvl_id = current_lvl_id;
    SET current_lvl_id = next_lvl_id;

    IF expected_sign IS NULL THEN
        SET expected_sign = sign(delta_lvl_val);
    END IF;
ELSE
    CALL delete_level(current_lvl_id);
    SET nb_bad_lvls = nb_bad_lvls + 1;

    IF current_lvl_id = f_lvl_id THEN
        SET current_lvl_id = next_lvl_id;
        SET prev_lvl_id = NULL;
        SET f_lvl_id = current_lvl_id;
        CALL reports_set_first_lvl_id(p_report_id, f_lvl_id);
    ELSE
        SET current_lvl_id = prev_lvl_id;
        SET prev_lvl_id = levels_get_prev_id(current_lvl_id);
    END IF;
END IF;
END LOOP;

UPDATE reports
SET nb_bad_levels = nb_bad_lvls
WHERE id = p_report_id;

INSERT INTO report_lvl_chains (id, lvl_chain) VALUES
(p_report_id, lvl_chain);
END$$

CREATE PROCEDURE remove_all_bad_levels()
BEGIN
DECLARE report_id INT;
DECLARE done INT DEFAULT FALSE;
DECLARE report_id_cur CURSOR FOR
    SELECT id
    FROM reports
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
CALL remove_all_bad_levels();

CALL display_bad_level_steps(616);
CALL display_safe_reports(1);

SET @puzzle1_answer = -1;
SELECT COUNT(*)
INTO @puzzle1_answer
FROM reports
WHERE nb_bad_levels = 0;

SET @puzzle2_answer = -1;
SELECT COUNT(*)
INTO @puzzle2_answer
FROM reports
WHERE nb_bad_levels <= 1;

SELECT @puzzle1_answer, @puzzle2_answer;

DROP DATABASE IF EXISTS day2;