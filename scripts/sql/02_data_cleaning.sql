-- Create a new table with clean, ready to analyze data.

	-- The script should:
		-- Trim blank spaces for VARCHARS
		-- Create ride_length calculated column
		-- Create a column called day_of_week on the day the ride started
		-- Create a numbered day of the week column to help with sorting in the Share phase (Project Instructions: Sunday = 1)
		-- Filter out: 
			-- November 2024 data, 
			-- station_id LIKE '%charging%', 
			-- ride_length < 60s OR ride_length > 24h
			
#############################################################################################################################################
-- Create clean table
CREATE TABLE 
	clean_trips_combined AS
SELECT * 
FROM (
	SELECT 
		TRIM(ride_id) AS ride_id, 
		TRIM(member_casual) AS member_casual,
		TRIM(rideable_type) AS rideable_type, 
		started_at,
		TRIM(TO_CHAR(started_at, 'Day')) AS day_of_week,
		EXTRACT(DOW FROM started_at) + 1 AS day_of_week_num,
		ended_at,
		ended_at - started_at AS ride_length,
		TRIM(start_station_name) AS start_station_name, 
		TRIM(start_station_id) AS start_station_id, 
		TRIM(end_station_name) AS end_station_name, 
		TRIM(end_station_id) AS end_station_id, 
		start_lat, 
		start_lng,
		end_lat, 
		end_lng
	FROM
		raw_trips_combined
) AS subquery
WHERE
	started_at >= '2024-12-01' AND
	(start_station_id NOT LIKE '%charging%' OR start_station_id IS NULL) AND
	(end_station_id NOT LIKE '%charging%' OR end_station_id IS NULL) AND
	ride_length > '00:01:00.00'  AND 
	ride_length < '24:00:00.00';
	
#############################################################################################################################################
-- After creating new table, explore it:

-- Check how many rows are left in the cleaned table:
SELECT
	COUNT(*) AS num_rows
FROM clean_trips_combined
-- 5,405,267 rows left out of the original 5,590,832: Data was cleaned successfully and reasonable amount of data was excluded. (Passed)

#############################################################################################################################################
-- Make sure there are no negative durations, rides shorter than a minute or longer than 24 hours:
SELECT 
	COUNT(ride_length) AS num_wrong_duration
FROM clean_trips_combined
WHERE 
	ride_length < '00:01:00.00' OR ride_length > '24:00:00.00'
-- No values outside of the specified range found. (Passed)

#############################################################################################################################################
-- Check if days of the week are properly created:
SELECT 
	DISTINCT day_of_week, 
	day_of_week_num
FROM clean_trips_combined
GROUP BY
	day_of_week, 
	day_of_week_num
ORDER BY
	day_of_week_num
-- Days of the week are created properly. (Passed)

#############################################################################################################################################
-- Make sure November 2024 data and station ids which include "charging" in their name are all excluded:
SELECT 
	started_at, start_station_id, end_station_id
FROM 
	clean_trips_combined
WHERE 
	started_at < '2024-12-01' OR
	start_station_id LIKE '%charging%' OR
	end_station_id LIKE '%charging%'
-- 0 rows returned. (Passed)