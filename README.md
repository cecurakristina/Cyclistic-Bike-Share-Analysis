# Cyclistic Bike-Share Analysis

## Project Overview
This project is a capstone case study for the Google Data Analytics Professional Certificate. It analyzes historical trip data from Cyclistic, a fictional bike-share program in Chicago, to identify usage patterns between annual members and casual riders.

## 1. Ask
### Business Task
The objective is to maximize Cyclistic’s profitable annual membership base by converting existing casual riders into members. Analyzing how annual members and casual riders use Cyclistic bikes differently will inform a targeted marketing strategy designed to achieve this conversion goal.

### Stakeholders
* **Lily Moreno:** Director of Marketing and manager.
* **Cyclistic Executive Team:** The decision-makers who must approve the proposed marketing program.

## 2. Prepare
### Data Source
The data used in this project was downloaded from https://divvy-tripdata.s3.amazonaws.com/index.html. It is owned by the **City of Chicago** and made available to the public by **Lyft Bikes and Scooters, LLC** (“Bikeshare”), formerly "Motivate".

### Data Format and Scope
The data for the past 12 months (**December 2024 through November 2025**) was downloaded in **.csv** format and stored locally in the project repository path.

### Data Credibility
The data credibility was assessed using the **ROCCC** principle (Reliable, Original, Comprehensive, Current, and Cited). This dataset passes the ROCCC quality check: 
* **Reliable:** The data is owned by a credible source - the City of Chicago.
* **Original:** It is a primary source collected directly by Bikeshare.
* **Comprehensive:** The information is sufficient to address the business task (e.g., `ride_id`, station names, timestamps, and `member_casual` rider types that separate casual riders from members).
* **Current:** The data accounts for post-pandemic shifts in urban mobility patterns, ensuring the analysis is relevant for 2026 strategic planning.
* **Cited:** The dataset is cited through the **Divvy Data License**.

### Data Limitations
A primary limitation of this dataset is the lack of personally identifiable information (PII). Additional demographic data (e.g., age or residency status) would allow for a more targeted marketing strategy, but the existing data is sufficient for the scope of this project.

### Data Security and Integrity
The raw data was secured by downloading it to a local environment and excluding it from the public GitHub history via `.gitignore` to comply with GitHub file size limits. Initial data integrity was verified by confirming a consistent schema across all 12 files and ensuring the presence of the primary key `ride_id` and the target variable `member_casual`. A more in-depth integrity analysis will follow in the **Process** phase.

## 3. Process

### Tools Used
* **SQL (PostgreSQL):** Chosen to handle the merging and the cleaning of over 5.5 million rows of data.

### Data Cleaning & Transformation Strategy
My goal for this phase was to transform a massive, messy dataset into a clean one that I could trust for the rest of the analysis. I didn't just want to remove rows; I wanted to engineer a table that was optimized for the visualization phase.

* **Subquery Architecture:** I used a nested subquery structure to define and clean my columns first. This allowed me to "wrap" the transformations (like trimming and math) so that I could easily filter them in the outer layer.
* **Logical Feature Engineering:**
    * **`ride_length`:** Calculated the duration of every trip.
    * **`day_of_week`, `day_of_week_num`:** I created two versions of the day of the week. One is the name (`Day`), and the other is a numeric index (`1 = Sunday`) to ensure my charts sort chronologically rather than alphabetically.
* **String Sanitization:** I applied `TRIM` to all Varchars. Even though some looked clean, I wanted to ensure that invisible white spaces wouldn't break my aggregations later.

### Logic Choices
I implemented strict boundary logic to ensure I was only analyzing "standard" rider behavior:

* **The "NULL" Preservation:** I realized that 30% of station names were missing. Instead of a filter that would have deleted 1.8 million rows, I used `OR IS NULL` logic to keep these records for my `NOT LIKE '%charging%'` stations filter.
* **Ride Duration:** I filtered out trips with negative durations (where the bike was docked before it started) and trips lasting less than 60 seconds, as these likely represent docking tests or accidental unlocks.
* **Cyclistic Policy:** I capped rides at 24 hours. Anything longer is flagged as lost or stolen by Cyclistic policy, so I excluded them to keep the focus on actual usage patterns.
* **"Charging" Stations:** I specifically targeted and removed `station_id` values containing "charging" to ensure I was only looking at consumer-facing data.

### Verification
I didn't consider the process finished until I ran verification queries to prove the integrity of the new table:
* Confirmed **0** rides shorter than 60 seconds.
* Confirmed **0** rides longer than 24 hours.
* Confirmed **0** "charging" stations remain.
* Final cleaned dataset consists of **5,405,267 rows**, retaining approximately 97% of the original data.

## 4. Analyze

### Tools Used
* **SQL (PostgreSQL):** Utilized for deep-dive analysis, window functions, and behavioral profiling across the 5.4 million row cleaned dataset.

### Analysis Strategy: Behavioral Profiling
To provide Lily Moreno with a conversion-focused strategy, I moved beyond basic counts. I looked at the **"When, How Long, and Where"** of rider behavior to build distinct personas for Members vs. Casual riders. My goal was to prove the **"Tourist vs. Commuter"** theory using data.


### Key Insights

#### 1. When
* While Members account for 2 out of every 3 rides in the system, Casual riders show a much higher reliance on weekends. 
* **37%** of all Casual trips happen on weekends, compared to only **24%** for Members.
* While the total number of rides is roughly equal on weekends and weekdays (~770k/day), the "market share" of Casual riders spikes significantly on Saturdays and Sundays.
* Member rides peak during morning and evening rush hours (5 AM–10 AM and 3 PM–8 PM). Casual rides peak in the evening.


#### 2. How Long
* **Average Trip Length:** Casual riders stay on bikes **65% longer** than Members on average (~20 minutes vs. ~12 minutes).
* **The Purpose:** Members treat Cyclistic as a utility (short, efficient bursts), while Casuals treat it as an experience (long, leisurely durations).


#### 3. Seasonal Preferences
* **Summer Peak:** Nearly half (**48%**) of all Casual rides for the entire year occur in the Summer months (June–August). 
* **Winter Resilience:** Members take **~10%** of their total annual trips in the winter, whereas Casual ridership drops to only **4.5%**. This reinforces the theory that Members use the bikes for essential transit while Casuals ride primarily for recreation.
  

#### 4. Where
The station data provided the strongest evidence of the "Tourist Profile":
* **Casual Top Stations:** Dominated by landmarks like **Navy Pier**, **Millennium Park**, and **Shedd Aquarium**.
* **Member Top Stations:** Clustered around corporate areas and major transit hubs like **Clinton St & Washington Blvd** (near Union Station).
* **Round Trips:** Casual riders took **twice as many round trips** as Members (107k vs 52k), proving a preference for sightseeing loops rather than point-to-point transit.


### Strategic Recommendations
Based on the data, I identified three primary opportunities for conversion:

* **The Weekend Membership:** Even though weekends only account for 28% of the week, they represent 37% of all Casual trips. This high intensity of weekend usage suggests a "Weekend-Only" membership would be a highly effective membership plan for riders who don't need the service for a Monday - Friday commute.
* **Summer/Seasonal Promotions:** With 48% of Casual activity in the summer, launching a Summer membership in May could lock in Casual users before their peak usage season begins.
* **Leisure Incentives:** Since Casual riders stay out 65% longer, a membership that offers longer "included" ride times (e.g., 45 minutes instead of 30) would specifically appeal to the longer-duration behavior of the Casual group.


## 5. Share

### Tools Used
**Tableau Public** 

### Data Storytelling & Visualizations
I designed the visuals to lead the executive team through the behavior gap I discovered in the Analyze phase.

* **The Volume Split (Donut Chart):** I visualized the total ridership to show that while Members provide the 65% "foundation," the 35% Casual riders (1.9M+ rides) is a massive, untapped revenue pool.
* **The "Commuter Curve" (Line Chart):** I plotted hourly ride volume which revealed a sharp "M-shape" for members (8 AM and 5 PM peaks) vs. a smooth "Afternoon Hill" for casuals. This visually proves that members use bikes for utility, while casuals use them for leisure. 
* **The Efficiency Gap (Bar Chart):** By comparing average trip duration, I demonstrated that Casual riders stay on the bikes nearly twice as long as Members. This visual serves to justify why a "commute-focused" membership might not currently appeal to them.
* **The Seasonal Heatmap (Area Chart):** I highlighted the "Summer Peak" for casual riders.
* **Geographic Hot Zones (Map):** I mapped the top stations by user type. The visual clustering of Casual riders along the Lakefront (Navy Pier, Millennium Park) vs. Members in the Loop provides a literal roadmap for physical advertisement placement. 

## 6. Act

### Conclusion & Executive Summary
The analysis concludes that Casual riders are not just "unregistered members", they are a different persona entirely. They are **"Weekend Warriors"** and **"Seasonal Sightseers."** To convert them, Cyclistic must pivot its value proposition from "Efficient Commuting" to "Unlimited Exploration."

### Final Recommendations
Based on the behavioral insights, I recommend the following strategies to Lily Moreno:

1.  **Introduce a "Seasonal Summer Pass":** Launch a 3-month membership specifically for the May–August window to cater to the casual riders who only use the service in the summer, eventually funneling them into full annual renewals.
2.  **Targeted Digital & Physical Marketing at "Leisure Hubs":** Instead of city-wide advertising, concentrate the marketing budget on the top 10 Lakefront stations identified in the geographic analysis. Promote membership benefits exactly where casual riders start their trips.
3.  **Tiered Membership Benefits for Long-Duration Rides:** Adjust membership tiers to include longer ride windows (e.g., 45 or 60 minutes). Since Casual riders average 20+ minute trips, showing them that a membership makes their long, leisurely rides more affordable is a direct path to conversion.
