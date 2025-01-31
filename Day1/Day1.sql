CREATE DATABASE IF NOT EXISTS DAY1;
USE DAY1;

CREATE TABLE IF NOT EXISTS Input (
	locationId1 INT,
	locationId2 INT
);

CREATE TABLE IF NOT EXISTS LeftList (
	id INT PRIMARY KEY AUTO_INCREMENT,
	locationId INT
);

CREATE TABLE IF NOT EXISTS RightList (
	id INT PRIMARY KEY AUTO_INCREMENT,
	locationId INT
);

-- Absolute path required
LOAD DATA LOCAL INFILE "Day1Sample.txt"
INTO TABLE Input
FIELDS TERMINATED BY "   "; -- 3 spaces

INSERT INTO LeftList (locationId) (
	SELECT locationId1
    FROM Input
    ORDER BY locationId1
);

INSERT INTO RightList (locationId) (
	SELECT locationId2
    FROM Input
    ORDER BY locationId2
);

CREATE OR REPLACE VIEW vLocations AS 
SELECT
	L.locationId AS leftLocation,
    R.locationId AS rightLocation
FROM LeftList L
INNER JOIN RightList R
ON L.id = R.id;

-- Puzzle 1
CREATE OR REPLACE VIEW vDistances AS 
SELECT
	leftLocation,
    rightLocation,
    ABS(leftLocation - rightLocation) AS distance
FROM vLocations;

SELECT *
FROM vDistances;

SELECT SUM(distance) AS puzzle1Result
FROM vDistances;

-- Puzzle 2
-- TODO

DROP DATABASE DAY1;
