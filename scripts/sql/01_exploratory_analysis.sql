-- Create table
CREATE TABLE raw_trips_combined (
    ride_id VARCHAR(255) PRIMARY KEY,
    rideable_type VARCHAR(50),
    started_at TIMESTAMP,
    ended_at TIMESTAMP,
    start_station_name VARCHAR(255),
    start_station_id VARCHAR(255),
    end_station_name VARCHAR(255),
    end_station_id VARCHAR(255),
    start_lat DOUBLE PRECISION,
    start_lng DOUBLE PRECISION,
    end_lat DOUBLE PRECISION,
    end_lng DOUBLE PRECISION,
    member_casual VARCHAR(50)
);
####################################################################################################################################################################################
-- Make sure all data was imported properly
SELECT 
    EXTRACT(YEAR FROM started_at) AS ride_year, 
    EXTRACT(MONTH FROM started_at) AS ride_month, 
    COUNT(*) AS num_of_rides
FROM raw_trips_combined
GROUP BY ride_year, ride_month
ORDER BY ride_year, ride_month;

-- Found 13 rows which started in November 2024 and ended in December 2024. 
-- In the cleaning script, I will filter them out to maintain a strict 12-month project scope (Dec 2024 - Nov 2025). 
-- The rest of the data was imported properly.

####################################################################################################################################################################################
-- Explore the data
SELECT * FROM raw_trips_combined
LIMIT 50;

####################################################################################################################################################################################
-- ride_id column is set as a PK, and since all the data was successfully imported without errors, there are no NULL values in this column.

####################################################################################################################################################################################
-- I see some null values in station names and ids, but these columns are not crucial for my analysis, so I don't need to drop them completely.
-- I can still use the trip length without station names, but I will check for the amount of missing names:
SELECT COUNT(*) AS missing_station_names_count
FROM raw_trips_combined
WHERE start_station_name IS NULL OR end_station_name IS NULL;

-- Over 30% of my data has missing names: 1,863,006 rows. That's a significant portion, so I will keep this data for now and possibly filter it out for specific relevant analysis.

####################################################################################################################################################################################
-- I noticed a station id that stood out - "chargingstx3" - which implies that this data might come from a Lyft employee taking bikes to a charging station and not a regular rider. 
-- This would affect my analysis as it doesn't display rider behavior. Checking for similar station names:
SELECT start_station_id, end_station_id
FROM raw_trips_combined
WHERE start_station_id LIKE '%charging%' OR end_station_id LIKE '%charging%';

-- Total rows where either start_id or end_id include the word "charging": 33,375. This is not an extremlely significant portion of the data compared to the total of over 5.5 mil rows.
-- I will exclude all those rows in the cleaning script as they might distort my analysis by portraying non-customer behavior.

####################################################################################################################################################################################
-- member_casual column is crucial for my analysis, so I should check for any missing data in that column and drop null values, if any:
SELECT COUNT(*)
FROM raw_trips_combined
WHERE member_casual IS NULL;

-- 0 null values in this column, nothing to drop.

####################################################################################################################################################################################
-- I should also check for logical errors such as start time > end time:
SELECT COUNT(*)
FROM raw_trips_combined
WHERE started_at > ended_at;

-- Found 29 logical errors where started_at > ended_at. This is a small number compared to the total of over 5.5 mil rows, so I will exclude these rows as well to ensure data quality.
####################################################################################################################################################################################
-- Finally, I should take into account any stolen bikes and rides that lasted longer/shorter than normal. 
-- I will check for the ride length range:
SELECT 
	MAX(ended_at - started_at) AS max_length,
	MIN(ended_at - started_at) AS min_length
FROM raw_trips_combined;

-- max_length: "1 day 02:14:54.011"
-- min_length: "-00:54:47.688"
-- As mentioned, I will exclude any rides that lasted < 0 sec.
-- However, I will be excluding rides that lasted less than 60 seconds as well, as they were probably just trials or mistakes and they don't reflect standard rider behavior.
-- The Divvy policy states the maximum rental time for a single trip is 24 hours. After 24 hours, the bike is flagged as "lost" or "stolen"
-- So I will also be excluding any rides lasting longer than 24h.

####################################################################################################################################################################################
-- NOTES FOR THE CLEANING SCRIPT:
-- Filter out: November 2024 data, station_id LIKE '%charging%', WHERE started_at > ended_at, duration < 60 sec OR duration > 24h.
-- Since I have started_at and ended_at columns, I should calculate trip_duration calculated column and make sure there are no negative durations.
-- Trim blank spaces