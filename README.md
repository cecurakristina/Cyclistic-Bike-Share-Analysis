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
