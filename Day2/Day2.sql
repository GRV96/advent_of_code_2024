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
    is_safe INT DEFAULT 0,
CONSTRAINT boolean CHECK (is_safe = 0 OR is_safe = 1)
);
TRUNCATE report;

CREATE TABLE IF NOT EXISTS safety (
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
TRUNCATE safety;

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

CREATE FUNCTION is_report_safe(p_report_id INT) RETURNS INT
READS SQL DATA
BEGIN
DECLARE is_safe INT;
DECLARE prev_lvl INT;
DECLARE current_lvl INT;
DECLARE delta_lvl INT;
DECLARE expected_sign INT;
SET expected_sign = NULL;

SELECT lvl0
INTO prev_lvl
FROM report
WHERE id = p_report_id;

IF prev_lvl IS NULL THEN
    RETURN TRUE;
END IF;

SELECT lvl1
INTO current_lvl
FROM report
WHERE id = p_report_id;

IF current_lvl IS NULL THEN
    RETURN TRUE;
END IF;

SET delta_lvl = current_lvl - prev_lvl;
SET is_safe = is_delta_safe(delta_lvl, expected_sign);
SET expected_sign = SIGN(delta_lvl);
SET prev_lvl = current_lvl;

SELECT lvl2
INTO current_lvl
FROM report
WHERE id = p_report_id;

IF current_lvl IS NULL THEN
    RETURN is_safe;
END IF;

SET delta_lvl = current_lvl - prev_lvl;
SET is_safe = is_delta_safe(delta_lvl, expected_sign);
SET prev_lvl = current_lvl;

SELECT lvl3
INTO current_lvl
FROM report
WHERE id = p_report_id;

IF current_lvl IS NULL THEN
    RETURN is_safe;
END IF;

SET delta_lvl = current_lvl - prev_lvl;
SET is_safe = is_delta_safe(delta_lvl, expected_sign);
SET prev_lvl = current_lvl;

SELECT lvl4
INTO current_lvl
FROM report
WHERE id = p_report_id;

IF current_lvl IS NULL THEN
    RETURN is_safe;
END IF;

SET delta_lvl = current_lvl - prev_lvl;
SET is_safe = is_delta_safe(delta_lvl, expected_sign);
SET prev_lvl = current_lvl;

SELECT lvl5
INTO current_lvl
FROM report
WHERE id = p_report_id;

IF current_lvl IS NULL THEN
    RETURN is_safe;
END IF;

SET delta_lvl = current_lvl - prev_lvl;
SET is_safe = is_delta_safe(delta_lvl, expected_sign);
SET prev_lvl = current_lvl;

SELECT lvl6
INTO current_lvl
FROM report
WHERE id = p_report_id;

IF current_lvl IS NULL THEN
    RETURN is_safe;
END IF;

SET delta_lvl = current_lvl - prev_lvl;
SET is_safe = is_delta_safe(delta_lvl, expected_sign);
SET prev_lvl = current_lvl;

SELECT lvl7
INTO current_lvl
FROM report
WHERE id = p_report_id;

IF current_lvl IS NULL THEN
    RETURN is_safe;
END IF;

SET delta_lvl = current_lvl - prev_lvl;
SET is_safe = is_delta_safe(delta_lvl, expected_sign);
SET prev_lvl = current_lvl;

RETURN is_safe;
END$$
DELIMITER ;

-- Absolute path required
LOAD DATA LOCAL INFILE "Day2Sample.txt"
INTO TABLE report
FIELDS TERMINATED BY " "
(lvl0, lvl1, lvl2, lvl3, lvl4, lvl5, lvl6, lvl7);

UPDATE report
SET is_safe = is_report_safe(id)
WHERE lvl0 IS NOT NULL;

SELECT *
FROM report;

SELECT COUNT(*)
FROM report
WHERE is_safe = TRUE;

DROP DATABASE IF EXISTS day2;