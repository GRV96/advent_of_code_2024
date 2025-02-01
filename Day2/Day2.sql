CREATE DATABASE IF NOT EXISTS day2;
USE day2;

CREATE TABLE IF NOT EXISTS report (
    id INT PRIMARY KEY UNIQUE AUTO_INCREMENT,
    lvl0 INT,
    lvl1 INT,
    lvl2 INT,
    lvl3 INT,
    lvl4 INT,
    lvl5 INT,
    lvl6 INT,
    lvl7 INT,
    nb_bad_levels INT
);
TRUNCATE report;

CREATE TABLE IF NOT EXISTS safety_steps (
    id INT PRIMARY KEY UNIQUE,
    lvl0 INT,
    lvl1 INT,
    lvl2 INT,
    lvl3 INT,
    lvl4 INT,
    lvl5 INT,
    lvl6 INT,
    lvl7 INT,
FOREIGN KEY (id) REFERENCES report(id)
);
TRUNCATE safety_steps;

DELIMITER $$
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

CREATE FUNCTION count_bad_levels(p_report_id INT) RETURNS INT
READS SQL DATA
BEGIN
DECLARE nb_bad_levels INT;
DECLARE prev_lvl INT;
DECLARE current_lvl INT;
DECLARE delta_lvl INT;
DECLARE expected_sign INT;
SET nb_bad_levels = 0;
SET expected_sign = NULL;

SELECT lvl0
INTO prev_lvl
FROM report
WHERE id = p_report_id;

INSERT INTO safety_steps (id, lvl0) VALUES
(p_report_id, nb_bad_levels);

IF prev_lvl IS NULL THEN
    RETURN nb_bad_levels;
END IF;

SELECT lvl1
INTO current_lvl
FROM report
WHERE id = p_report_id;

IF current_lvl IS NULL THEN
    RETURN nb_bad_levels;
END IF;

SET delta_lvl = current_lvl - prev_lvl;
IF NOT is_delta_safe(delta_lvl, expected_sign) THEN
    SET nb_bad_levels = nb_bad_levels + 1;
END IF;
SET prev_lvl = current_lvl;
SET expected_sign = SIGN(delta_lvl);

UPDATE safety_steps
SET lvl1 = nb_bad_levels
WHERE id = p_report_id;

SELECT lvl2
INTO current_lvl
FROM report
WHERE id = p_report_id;

IF current_lvl IS NULL THEN
    RETURN nb_bad_levels;
END IF;

SET delta_lvl = current_lvl - prev_lvl;
IF NOT is_delta_safe(delta_lvl, expected_sign) THEN
    SET nb_bad_levels = nb_bad_levels + 1;
END IF;
SET prev_lvl = current_lvl;

UPDATE safety_steps
SET lvl2 = nb_bad_levels
WHERE id = p_report_id;

SELECT lvl3
INTO current_lvl
FROM report
WHERE id = p_report_id;

IF current_lvl IS NULL THEN
    RETURN nb_bad_levels;
END IF;

SET delta_lvl = current_lvl - prev_lvl;
IF NOT is_delta_safe(delta_lvl, expected_sign) THEN
    SET nb_bad_levels = nb_bad_levels + 1;
END IF;
SET prev_lvl = current_lvl;

UPDATE safety_steps
SET lvl3 = nb_bad_levels
WHERE id = p_report_id;

SELECT lvl4
INTO current_lvl
FROM report
WHERE id = p_report_id;

IF current_lvl IS NULL THEN
    RETURN nb_bad_levels;
END IF;

SET delta_lvl = current_lvl - prev_lvl;
IF NOT is_delta_safe(delta_lvl, expected_sign) THEN
    SET nb_bad_levels = nb_bad_levels + 1;
END IF;
SET prev_lvl = current_lvl;

UPDATE safety_steps
SET lvl4 = nb_bad_levels
WHERE id = p_report_id;

SELECT lvl5
INTO current_lvl
FROM report
WHERE id = p_report_id;

IF current_lvl IS NULL THEN
    RETURN nb_bad_levels;
END IF;

SET delta_lvl = current_lvl - prev_lvl;
IF NOT is_delta_safe(delta_lvl, expected_sign) THEN
    SET nb_bad_levels = nb_bad_levels + 1;
END IF;
SET prev_lvl = current_lvl;

UPDATE safety_steps
SET lvl5 = nb_bad_levels
WHERE id = p_report_id;

SELECT lvl6
INTO current_lvl
FROM report
WHERE id = p_report_id;

IF current_lvl IS NULL THEN
    RETURN nb_bad_levels;
END IF;

SET delta_lvl = current_lvl - prev_lvl;
IF NOT is_delta_safe(delta_lvl, expected_sign) THEN
    SET nb_bad_levels = nb_bad_levels + 1;
END IF;
SET prev_lvl = current_lvl;

UPDATE safety_steps
SET lvl6 = nb_bad_levels
WHERE id = p_report_id;

SELECT lvl7
INTO current_lvl
FROM report
WHERE id = p_report_id;

IF current_lvl IS NULL THEN
    RETURN nb_bad_levels;
END IF;

SET delta_lvl = current_lvl - prev_lvl;
IF NOT is_delta_safe(delta_lvl, expected_sign) THEN
    SET nb_bad_levels = nb_bad_levels + 1;
END IF;
SET prev_lvl = current_lvl;

UPDATE safety_steps
SET lvl7 = nb_bad_levels
WHERE id = p_report_id;

RETURN nb_bad_levels;
END$$
DELIMITER ;

-- Absolute path required
LOAD DATA LOCAL INFILE "Day2Sample.txt"
INTO TABLE report
FIELDS TERMINATED BY " "
(lvl0, lvl1, lvl2, lvl3, lvl4, lvl5, lvl6, lvl7);

UPDATE report
SET nb_bad_levels = count_bad_levels(id)
WHERE id IS NOT NULL;

SELECT *
FROM report;

SELECT *
FROM safety_steps;

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