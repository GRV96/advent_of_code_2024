CREATE DATABASE IF NOT EXISTS day1;
USE day1;

CREATE TABLE IF NOT EXISTS input (
    location_id_left INT,
    location_id_right INT
);

CREATE TABLE IF NOT EXISTS left_list (
    id INT PRIMARY KEY AUTO_INCREMENT,
    location_id INT
);

CREATE TABLE IF NOT EXISTS right_list (
    id INT PRIMARY KEY AUTO_INCREMENT,
    location_id INT
);

-- Absolute path required
LOAD DATA LOCAL INFILE "Day1Puzzle.txt"
INTO TABLE input
FIELDS TERMINATED BY "   "; -- 3 spaces

INSERT INTO left_list (location_id) (
    SELECT location_id_left
    FROM input
    ORDER BY location_id_left
);

INSERT INTO right_list (location_id) (
    SELECT location_id_right
    FROM input
    ORDER BY location_id_right
);

-- Puzzle 1
CREATE OR REPLACE VIEW v_locations AS 
SELECT
    l.location_id AS left_location,
    r.location_id AS right_location
FROM left_list l
INNER JOIN right_list r
ON l.id = r.id;

CREATE OR REPLACE VIEW v_distances AS 
SELECT
    left_location,
    right_location,
    ABS(left_location - right_location) AS distance
FROM v_locations;

SET @puzzle1_answer = -1;
SELECT SUM(distance)
INTO @puzzle1_answer
FROM v_distances;

-- Puzzle 2
CREATE TABLE IF NOT EXISTS loc_id_occurrences (
    loc_id INT,
    nb_occurrences INT
);

DELIMITER $$
CREATE FUNCTION count_id_occurrences(p_location_id INT) RETURNS INT
READS SQL DATA
BEGIN
DECLARE nb_loc_id_occs INT;

SELECT nb_occurrences
INTO nb_loc_id_occs
FROM loc_id_occurrences
WHERE loc_id = p_location_id;

IF nb_loc_id_occs IS NULL THEN
    SELECT COUNT(location_id)
    INTO nb_loc_id_occs
    FROM right_list
    WHERE location_id = p_location_id;
    
    IF nb_loc_id_occs IS NULL THEN
        SET nb_loc_id_occs = 0;
    END IF;

    INSERT INTO loc_id_occurrences VALUES
    (p_location_id, nb_loc_id_occs);
END IF;

RETURN nb_loc_id_occs;
END$$
DELIMITER ;

SET @puzzle2_answer = -1;
SELECT SUM(location_id * count_id_occurrences(location_id))
INTO @puzzle2_answer
FROM left_list;

SELECT @puzzle1_answer, @puzzle2_answer;

DROP DATABASE day1;
