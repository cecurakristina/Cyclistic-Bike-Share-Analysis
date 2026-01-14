/*
Business task: Compare casual riders to members
Goal: Marketing strategy suggestions to convert casual riders into members

Which insights can I gain from the data provided that would support the business task and goal?

1.	Bike type preference comparison
2.	Time of day comparison (started_at) 
3.	Weekdays VS weekends comparison
4.	Seasonal comparison
5.	Ride length comparison
6.	Top most popular start and end stations for each group
7.	Round trips (round trip membership promos)
8.	Routes (employee discounts, marketing target areas...)
*/


-- First, I will add a day_type (weekday or weekend) column to make future queries easier to write
ALTER TABLE clean_trips_combined
ADD day_type VARCHAR(50);

UPDATE clean_trips_combined
SET day_type = 
	CASE
		WHEN day_of_week_num IN (1, 7) THEN 'weekend'
		ELSE 'weekday'
	END
WHERE day_type IS NULL;

-- Check if query executed successfully:
SELECT * FROM clean_trips_combined LIMIT 10;

-- day_type successfully added to the table

##############################################################################################################################################################################################################################
-- 1. Bike type preference comparison
SELECT
	member_casual,
	rideable_type,
	COUNT(rideable_type) AS num_type
FROM
	clean_trips_combined
GROUP BY
	member_casual,
	rideable_type;
	
-- CASUAL: classic ~ 670k; electric ~ 1.2 mil
-- MEMBER: classic ~ 1.2 mil; electric ~2.2 mil
-- Conclusion: 
	-- Both groups prefer electric bikes (around twice as much in both cases).
	-- Members ride both bike types around twice as much as casual riders.
	
##############################################################################################################################################################################################################################
-- 2. Time of day and day of week comparison
-- Explore 4 categories - morning rush (5AM - 10AM), midday/lunch (10AM - 3PM), evening rush (3PM - 8PM), night (8PM - 5AM)

-- subquery: inner - create time of day in cleaned set; outer -select relevant columns including new one and group by

SELECT
	member_casual,
	time_of_day,
	COUNT (time_of_day) AS num_trips,
	ROUND(COUNT(*) / SUM(COUNT(*)) OVER(PARTITION BY member_casual) * 100.0, 2)  AS percent_rider_type_trips,
	ROUND(COUNT(*) / SUM(COUNT(*)) OVER() * 100.0, 2)  AS percent_total_trips
FROM (
	SELECT
		*,
		CASE
			WHEN EXTRACT (HOUR FROM started_at) >= 5 AND EXTRACT (HOUR FROM started_at) < 10 THEN 'morning_rush'
			WHEN EXTRACT (HOUR FROM started_at) >= 10 AND EXTRACT (HOUR FROM started_at) < 15 THEN 'midday'
			WHEN EXTRACT (HOUR FROM started_at) >= 15 AND EXTRACT (HOUR FROM started_at) < 20 THEN 'evening_rush'
			ELSE 'night'
		END AS time_of_day
	FROM clean_trips_combined
)
GROUP BY
	member_casual,
	time_of_day
ORDER BY
	num_trips DESC;
-- MEMBER DESC: evening_rush (~1.4mil, 41%), midday (~862k, 25%), morning_rush (~746k, 21%), night (~451k, 13%)
-- CASUAL DESC: evening_rush (~773k, 40%), midday (~572k, 30%), night (~350k, 18%), morning_rush (~221k, 12%)
-- Conclusion:
	-- Both groups ride the most during the evening_rush and followed by midday. 
	-- Discounted evening memberships might be a good idea to convert casuals to evening members.
	-- Causal riders ride the least in the morning. Limited amount of free morning rides might change their mind and convince them to start commuting to work.
	-- Night trips account for a larger portion of a Casual rider's habits (18%) compared to Members (13%). Night memberships might be a good idea to convert them to members.
	-- Casual riders might be riding more on weekend nights, so I will look into this next.
	
##############################################################################################################################################################################################################################
-- I will now compare the percentages of weekend and weekday rides between casual riders and members:
SELECT 
	member_casual,
	COUNT(member_casual) AS num_riders
FROM
	clean_trips_combined
GROUP BY member_casual;

-- We can see that this dataset contains data for ~1.9 mil casual riders and ~3.5 mil members. 
-- We conclude that around every 2 out of 3 rides of the dataset are members.

SELECT 
	member_casual,
	day_type,
	COUNT(*) AS num_trips,
	ROUND(COUNT(*)/ SUM(COUNT(*)) OVER (PARTITION BY member_casual) * 100, 2) AS percent_rider_type,
	ROUND(COUNT(*) / SUM(COUNT(*)) OVER() * 100, 2) AS percent_total
FROM 
	clean_trips_combined
GROUP BY
	member_casual,
	day_type;

-- Within the group:
-- CASUAL: weekday 63%, weekend 37%
-- MEMBER: weekday 75%, weekend 24%
-- We can see that compared to members (24%), weekend rides account more (37%) to the casual riders for the total amount of rides per group.
-- This shows that our casual riders are more likely to ride on weekends, so we can consider weekend memberships as a marketing strategy recommendation.
-- When looking at the total number of rides across the rider type, the percentage of weekend rides accounts to nearly as many casual riders (13%) as it does to members(15%).

SELECT 
	day_type,
	COUNT(*)
FROM 
	clean_trips_combined
GROUP BY
	day_type;
	
-- We see that ~3.9mil sales happen on weekdays and ~1.5mil sales on weekends.
-- Since weekdays have 5 days, and weekends only 2, I will calculate average weekend VS weekday sales per day below.

SELECT 
	day_type,
	ROUND(COUNT(*) /
	(CASE
		WHEN day_type = 'weekday' THEN 5.0
		WHEN day_type = 'weekend' THEN 2.0
		END), 2) AS avg_rides
FROM 
	clean_trips_combined
GROUP BY
	day_type;

-- After dividing weekday sales by 5, we get an average of ~774k sales/day on weekdays.
-- After dividing weekend sales by 2, we get an average of ~767k sales/day on weekends.
-- So, the average amount of sales per day is about the same on weekdays and weekends.

-- This analysis shows us that:
	-- 1. only 1/3 of riders are casual riders
	-- 2. weekends are just as busy as weekdays
	-- 3. even though every 2 out of 3 rides is by members, casual riders take up almost as much of weekend sales as members
	-- 4. casual riders prefer riding on weekends more than members (24% of member rides VS 37% casual rides are weekend rides)

-- COUNCLUSION:
-- Casual riders ride more on weekends, so weekend memberships might convert them to members.
-- Since they don't ride as much on weekdays, offering casual members to try a limited number of free weekday rides might make them consider biking to work.
-- Since members don't ride as much on weekends, but weekends are just as busy as weekdays, putting more bikes in the touristy areas on weekends, and more bikes in the corporate areas during the week might be a smart move.

##############################################################################################################################################################################################################################
-- Next, I will look into seasonal differences:

SELECT
	member_casual,
	season,
	COUNT(*) AS num_trips,
	ROUND((COUNT(*) * 100.0) / SUM(COUNT(*)) OVER(PARTITION BY member_casual), 2) AS percentage_trips
FROM(
	SELECT
		*,
		EXTRACT(MONTH FROM started_at) AS month,
		CASE
			WHEN EXTRACT(MONTH FROM started_at) > 2 AND EXTRACT(MONTH FROM started_at) < 6 THEN 'spring'
			WHEN EXTRACT(MONTH FROM started_at) > 5 AND EXTRACT(MONTH FROM started_at) < 9 THEN 'summer'
			WHEN EXTRACT(MONTH FROM started_at) > 8 AND EXTRACT(MONTH FROM started_at) < 12 THEN 'fall'
			ELSE 'winter'
		END AS season
	FROM
		clean_trips_combined
) AS subquery
GROUP BY
	member_casual,
	season
ORDER BY
	member_casual,
	percentage_trips DESC;

-- PARTITION BY season:
-- CASUAL: winter (19%) -> spring (32%) -> fall (34%) -> summer (42%)
-- MEMBERS: winter(81%) ->  spring(68%) -> fall(66%) ->  summer (58%)  
-- We see that in every season members account for more rides, but we also know that every 2 out of 3 rides are member rides, so that makes sense.

-- When changing PARTITION BY to member_casual, we can see the percentage of rides within rider type per season:
-- CASUAL: summer(48%) -> fall(29%) -> spring(19%) -> winter (4.5%) 
-- MEMBER: summer(36%) -> fall(32%) -> spring(22%) -> winter(10%)
-- This analysis clearly shows that both rider types have the same seasonal preference.
-- However, casual riders prefer to ride in the summer even more than members, and members ride twice as much as casual riders in the winter.
-- Nearly half of casual rides happen in the summer, while members seasonal rides are more evenly distributed.
-- So far, we learned that casual riders prefer riding on evenings, weekends and in the summer. A membership that caters to these preferences has a potential to turn casual riders into members.

##############################################################################################################################################################################################################################
-- Now, I will look at the ride length differences between the 2 groups:
SELECT 
	member_casual,
	AVG(ride_length) AS avg_ride_length,
	MIN(ride_length) AS shortest_ride,
    MAX(ride_length) AS longest_ride
FROM 
	clean_trips_combined
GROUP BY
	member_casual;

-- The AVG length of CASUAL rides is ~20 minutes, while the AVG length of MEMBER rides is ~12 minutes.
-- Casual rides are approximately 65% longer than Member rides on average!
-- Summer weekend membership promotions that allow for longer rides at no additional cost/minute might be a good way to convert some casual riders into members.
-- Based on all the casual riders preferences, they fit the "tourist" profile, so offering shorter memberships (weekly, monthly, weekend passes...) might also be a good idea.

##############################################################################################################################################################################################################################
-- To take a closer look into the tourist VS commuter theory, I will explore and compare the routes between the 2 rider types.
-- I will start with top 10 station for members:
SELECT 
	start_station_name,
	COUNT(*) AS start_station_count
FROM 
	clean_trips_combined
WHERE
	member_casual = 'member'
GROUP BY
	start_station_name
ORDER BY
	start_station_count DESC
LIMIT 10;
/*
"Kingsbury St & Kinzie St"	31728
"Clinton St & Washington Blvd"	25448
"Clinton St & Madison St"	22084
"Canal St & Madison St"	21968
"Clark St & Elm St"	21165
"Wells St & Elm St"	19072
"State St & Chicago Ave"	18943
"Clinton St & Jackson Blvd"	18270
"Wells St & Concord Ln"	18246
"Wells St & Huron St"	17715
*/
SELECT 
	start_station_name,
	COUNT(*) AS start_station_count
FROM 
	clean_trips_combined
WHERE
	member_casual = 'casual'
GROUP BY
	start_station_name
ORDER BY
	start_station_count DESC
LIMIT 10;

/*
"DuSable Lake Shore Dr & Monroe St"	30849
"Navy Pier"	26647
"Streeter Dr & Grand Ave"	23664
"Michigan Ave & Oak St"	22094
"DuSable Lake Shore Dr & North Blvd"	19022
"Millennium Park"	18781
"Shedd Aquarium"	16707
"Dusable Harbor"	15519
"Theater on the Lake"	15452
"Michigan Ave & 8th St"	11064
*/

-- This quick analysis shows that touristic spots such as Navy Pier and Shed aquarium tend to be more popular among casual riders.
-- Stations around major transit hubs like Clinton St near Union Station seem to be more popular among members which supports my  tourist VS commuter theory.

-- I will now take a closer look into roundtrip routes. Tourists are more likely to explore the city and return the bike at the same dock, whereas commuters usually start at home and dock it around their workplace.
-- Let's see if casual riders account for more round trip rides than members:

SELECT 
	member_casual,
	COUNT(*) AS num_round_trip
FROM 
	clean_trips_combined
WHERE
	start_station_name = end_station_name
GROUP BY
	member_casual;
	
-- CASUAL round trips: ~107k
-- MEMBER round trips: ~52k
-- Seeing how more than twice as many round trips are taken by casual members, this further supports my tourist VS commuter theory.

-- Finally, I will look into most popular routes for each group, which I will further explore in the Share phase of this project.
-- Top 10 routes for members:
SELECT 
	DISTINCT CONCAT(start_station_name, ' - ', end_station_name) AS route,
	COUNT(*) AS num_rides
FROM 
	clean_trips_combined
WHERE
	member_casual = 'member' AND 
	(start_station_name IS NOT NULL AND 
	end_station_name IS NOT NULL AND
	start_station_name != '' AND
	end_station_name != '')
GROUP BY
	route
ORDER BY
	num_rides DESC
LIMIT 10;
/*
"Ellis Ave & 60th St - Ellis Ave & 55th St"	3487
"Ellis Ave & 55th St - Ellis Ave & 60th St"	3365
"University Ave & 57th St - Ellis Ave & 60th St"	3199
"Ellis Ave & 60th St - University Ave & 57th St"	3137
"Blackstone Ave & 59th St - University Ave & 57th St"	1589
"University Ave & 57th St - Kimbark Ave & 53rd St"	1542
"University Ave & 57th St - Blackstone Ave & 59th St"	1527
"Calumet Ave & 33rd St - State St & 33rd St"	1433
"Kimbark Ave & 53rd St - University Ave & 57th St"	1426
"Ellis Ave & 55th St - Kimbark Ave & 53rd St"	1373
*/

-- Top 10 routes for casual riders:
SELECT 
	DISTINCT CONCAT(start_station_name, ' - ', end_station_name) AS route,
	COUNT(*) AS num_rides
FROM 
	clean_trips_combined
WHERE
	member_casual = 'casual' AND 
	(start_station_name IS NOT NULL AND 
	end_station_name IS NOT NULL AND
	start_station_name != '' AND
	end_station_name != '')
GROUP BY
	route
ORDER BY
	num_rides DESC
LIMIT 10;
/*
"DuSable Lake Shore Dr & Monroe St - DuSable Lake Shore Dr & Monroe St"	6098
"Navy Pier - Navy Pier"	5038
"Streeter Dr & Grand Ave - Streeter Dr & Grand Ave"	3927
"Michigan Ave & Oak St - Michigan Ave & Oak St"	3830
"DuSable Lake Shore Dr & Monroe St - Navy Pier"	2652
"Millennium Park - Millennium Park"	2585
"Dusable Harbor - Dusable Harbor"	2441
"DuSable Lake Shore Dr & Monroe St - Streeter Dr & Grand Ave"	2311
"Shedd Aquarium - DuSable Lake Shore Dr & Monroe St"	2026
"Montrose Harbor - Montrose Harbor"	1708
*/

-- I will further explore these routes on maps and with the visualization tools.

--SUMMARY:
-- This analysis helped me understand that casual riders fit the "tourist" profile:
	-- 1. They prefer riding on evenings, weekends, and in the summer.
	-- 2. They ride for longer and take more than double the amount of round trips (107k vs 52k).
	-- 3. They ride around touristy areas compared to commute areas members mostly take.
-- I've also learned that both groups prefer riding electric bikes.