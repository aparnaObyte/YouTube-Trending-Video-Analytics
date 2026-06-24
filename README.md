# YouTube Trending Video Analytics

## 📌 Project Overview

The core focus of this project is to analyze YouTube's trending video data across five countries to uncover what drives a video onto the trending list, how that differs by region, and whether title sentiment relates to video performance.

## 🎯 Objective

To process and analyze 178,580 trending video records from the US, UK, India, Japan, and Germany (Nov 2017–Jun 2018) using SQL, Python, and sentiment analysis, and present the findings through visualizations and an interactive Tableau dashboard.

---

## 🛠️ Tools & Tech Stack

- **Database Engine:** SQLite (DB Browser for SQLite)
- **Language:** SQL, Python
- **Libraries:** Pandas, Matplotlib, Seaborn, VADER Sentiment
- **Visualization:** Tableau Public
- **Core Concepts:**
  - Data cleaning and merging (pd.concat())
  - SQL aggregation (GROUP BY, SUM(), AVG(), COUNT())
  - Sentiment scoring (VADER compound score)
  - Correlation analysis
  - Dashboard design (KPI cards, heatmaps, bubble maps)

---

## 📁 Dataset

Source: Trending YouTube Video Statistics — https://www.kaggle.com/datasets/datasnaek/youtube-new

Five country-level CSV files (US, GB, IN, JP, DE), each with daily snapshots of trending videos including views, likes, dislikes, comment count, category, and title. Combined, the five files total 178,580 rows covering November 2017 to June 2018.

Raw CSV files are not included in this repo due to size — download them directly from the Kaggle link above if you want to reproduce the analysis.

**A note on data quality:** the dataset is daily-snapshot data, not a clean transactional log, so a few quirks should be read as collection artifacts rather than real-world patterns. Daily trending volume jumps from ~800 to ~950 videos/day around February 2018 with no gradual ramp, which points to a change in how many videos were captured per day rather than an actual spike in activity. The US also holds a perfectly flat count of exactly 200 trending videos every single day in the dataset, which is a strong sign of a fixed collection limit rather than true daily behavior. These are called out directly in the Limitations section of the full report.

---

## 📂 Repository Structure
YouTube-Trending-Video-Analytics/

├── Reports/

│   ├── FINAL REPORT.pdf

│   └── YouTube_Trending_Data_Storytelling_Report.pdf

├── Tableau Dasboard.png

├── YouTube Trending Video Analytics Dashboard.twb

├── YouTube_Trending_Analysis.ipynb

└── sql_youtube_trending_analysis_documented.sql

| File / Folder | Description |
|------|-------------|
| Reports/FINAL REPORT.pdf | One-page internship submission summary |
| Reports/YouTube_Trending_Data_Storytelling_Report.pdf | Full data storytelling report with all chart screenshots |
| Tableau Dasboard.png | Screenshot of the published dashboard |
| YouTube Trending Video Analytics Dashboard.twb | Tableau workbook file |
| YouTube_Trending_Analysis.ipynb | Main notebook — data loading, cleaning, sentiment analysis, visualizations |
| sql_youtube_trending_analysis_documented.sql | Commented SQL queries used for the analysis |

---

## 📊 Live Dashboard

🔗 View the dashboard on Tableau Public: https://public.tableau.com/app/profile/aparna.o3244/viz/YouTubeTrendingVideoAnalyticsDashboard/Dashboard1?publish=yes

---

## 🔍 Key Findings

- A small set of global hits — mostly music videos and YouTube Rewind — dominates total views. Nicky Jam x J. Balvin's "X (EQUIS)" leads with 420M+ views.
- Category dominance differs by country: Entertainment leads in Germany, the UK, the US, and Japan; India is the outlier with Music as its top category.
- The UK has the highest average views per video (5.91M) — more than double the US (2.36M).
- Daily trending volume jumps from ~800/day to ~950/day around February 2018, likely a data collection artifact. The US holds a flat 200 videos/day throughout.
- Likes and views are strongly correlated (0.79); dislikes correlate weakly with views (0.41).
- Talk shows and recurring channels (The Late Show, WWE, The Ellen Show) dominate trending frequency through constant uploads.
- Negative-sentiment titles are the smallest group (~27K of 178,580) but average nearly double the views of neutral titles (3.61M vs. 1.85M).
- Trending activity is fairly even across days of the week.

Full write-up with charts is in Reports/.

---

## ⚠️ Limitations

- Dataset covers a fixed seven-month window (Nov 2017–Jun 2018); findings may not generalize to current trends.
- Sentiment analysis was based primarily on titles; descriptions and thumbnails were not analyzed.
- The sentiment–views relationship is correlational, not causal.
