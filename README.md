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
