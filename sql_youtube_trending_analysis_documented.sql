/* ============================================================
   YOUTUBE TRENDING VIDEO ANALYTICS — SQL ANALYSIS
   Dataset: Trending video CSVs for US, GB, IN, JP, DE
   Source: Kaggle (YouTube New / Trending Video Statistics)
   Combined table: all_videos (178,580 rows across 5 countries)
   ============================================================ */


/* ------------------------------------------------------------
   SETUP: Combine all 5 country tables into one master table
   Each row tagged with its country of origin for filtering
   and comparison across the whole analysis.
   ------------------------------------------------------------ */
CREATE TABLE all_videos AS
SELECT *, 'US' as country FROM USvideos
UNION ALL
SELECT *, 'GB' as country FROM GBvideos
UNION ALL
SELECT *, 'IN' as country FROM INvideos
UNION ALL
SELECT *, 'JP' as country FROM JPvideos
UNION ALL
SELECT *, 'DE' as country FROM DEvideos;

-- Sanity check: confirm total row count after merge
SELECT COUNT(*) FROM all_videos;
-- Result: 178,580 rows


/* ------------------------------------------------------------
   QUERY 1: Top 3 Most Viewed Videos from the Top 3 Countries
   Purpose: Identify which countries generate the highest total
   views, then surface their most-watched individual videos.
   Approach: Window function (ROW_NUMBER) ranks videos within
   each country by max views; outer filter limits to countries
   ranked highest by total view volume.
   ------------------------------------------------------------ */
SELECT country, title, max_views
FROM (
    SELECT country, title, MAX(views) AS max_views,
    ROW_NUMBER() OVER (PARTITION BY country ORDER BY MAX(views) DESC) AS rank
    FROM all_videos
    GROUP BY country, title
)
WHERE rank <= 3
AND country IN (
    SELECT country FROM all_videos
    GROUP BY country
    ORDER BY sum(views) DESC
);
/* Result: GB's top video (Nicky Jam x J. Balvin - X (EQUIS)) hit
   424.5M views, the single highest figure in the dataset. US,
   IN, and DE top spots are dominated by YouTube Rewind 2017,
   Avengers: Infinity War trailer, and BTS 'FAKE LOVE'. */


/* ------------------------------------------------------------
   QUERY 2: Top 3 Trending Categories by Country
   Purpose: Find which video categories appear most often in
   the trending list for each country (by frequency, not views).
   Approach: Count rows per category per country, rank with
   ROW_NUMBER, keep top 3 per country.
   ------------------------------------------------------------ */
SELECT country,category_id, trending_count
FROM (
    SELECT country, category_id, COUNT(*) AS trending_count,
    ROW_NUMBER() OVER (PARTITION BY country ORDER BY COUNT(*) DESC) AS rank
    FROM all_videos
    GROUP BY country, category_id
)
WHERE rank <= 3;
/* Result: Category 24 (Entertainment) is the #1 trending
   category in 4 of 5 countries (DE, IN, JP, US). GB is the
   outlier, with Category 10 (Music) trending most often. */


/* ------------------------------------------------------------
   QUERY 3: Average Views and Likes by Country
   Purpose: Compare overall engagement levels across countries
   to see which audiences drive the highest average performance.
   ------------------------------------------------------------ */
SELECT country, round(AVG(views),2) AS avg_views, round(AVG(likes),2) AS avg_likes
FROM all_videos
GROUP BY country;
/* Result: GB has by far the highest average views (5.91M) and
   likes (134.5K) per trending video — more than double the next
   highest country (US, 2.36M avg views). JP is lowest on both
   metrics (262K avg views, 8K avg likes). */


/* ------------------------------------------------------------
   QUERY 4: Videos Trending Across Multiple Countries
   Purpose: Identify videos with genuine global reach — content
   that trended in more than one country, not just locally.
   ------------------------------------------------------------ */
SELECT title, COUNT(DISTINCT country) AS country_count
FROM all_videos
GROUP BY title
HAVING country_count > 1
ORDER BY country_count DESC
LIMIT 10;
/* Result: Several movie trailers (VENOM, Avengers: Infinity War,
   Spider-Man: Into the Spider-Verse, Mission Impossible - Fallout)
   and major music releases (The Chainsmokers, Taylor Swift)
   trended in all 5 countries simultaneously — confirming the
   dashboard's "globally viral" insight is backed by real data. */


/* ------------------------------------------------------------
   QUERY 5: Like-to-Dislike Ratio by Country
   Purpose: Measure overall sentiment/reception quality by
   country, using the likes:dislikes ratio as a proxy.
   Note: Filters out rows where dislikes = 0 to avoid divide-
   by-zero errors.
   ------------------------------------------------------------ */
SELECT country, round(AVG(likes * 1.0 / dislikes),2) AS avg_like_dislike_ratio
FROM all_videos
WHERE dislikes > 0
GROUP BY country
ORDER BY avg_like_dislike_ratio DESC;
/* Result: GB has the most favorable like:dislike ratio (48.99
   likes per dislike), followed by US (43.97). IN has the lowest
   ratio (18.16), suggesting more polarized or critical audience
   reception relative to other countries. */


/* ------------------------------------------------------------
   QUERY 6: Most Commented Videos by Country
   Purpose: Surface the videos generating the most discussion
   (comment volume) per country — a different engagement signal
   than views or likes.
   ------------------------------------------------------------ */
SELECT country, title, max_comments
FROM (
    SELECT country, title, MAX(comment_count) AS max_comments,
    ROW_NUMBER() OVER (PARTITION BY country ORDER BY MAX(comment_count) DESC) AS rank
    FROM all_videos
    GROUP BY country, title
)
WHERE rank <= 3;
/* Result: BTS 'FAKE LOVE' and YouTube Rewind 2017 appear as
   top-commented videos across nearly every country, reinforcing
   their status as cross-border viral hits identified in Query 4. */


/* ------------------------------------------------------------
   QUERY 7: Most Controversial Videos (High Views, Low Likes)
   Purpose: Find videos that reached large audiences (1M+ views)
   but received unusually poor like rates — a signal of
   negative reception despite high reach.
   ------------------------------------------------------------ */
SELECT title, country, MAX(views) AS max_views, MAX(likes) AS max_likes,
(MAX(likes) * 1.0 / MAX(views)) AS like_rate
FROM all_videos
WHERE views > 1000000
AND likes > 0
GROUP BY title, country
ORDER BY like_rate ASC
LIMIT 10;
/* Result: Movie trailers and ad placements (e.g., "Show Dogs"
   trailer, Super Bowl commercials) dominate this list — high
   reach but very low like-rates, consistent with skippable-ad
   or low-interest-content behavior rather than genuine backlash. */


/* ------------------------------------------------------------
   QUERY 8: Total Unique Trending Videos by Country
   Purpose: Measure content variety/turnover per country — more
   unique videos suggests a faster-changing trending list.
   ------------------------------------------------------------ */
SELECT country, COUNT(DISTINCT title) AS unique_videos
FROM all_videos
GROUP BY country
ORDER BY unique_videos DESC;
/* Result: DE has by far the most unique trending videos (29,682),
   while GB has the fewest (3,369) despite GB having some of the
   highest average view counts — suggesting GB's trending list is
   dominated by a smaller, more persistent set of viral hits. */


/* ------------------------------------------------------------
   QUERY 9: Most Active Trending Month by Country
   Purpose: Identify which calendar month had the highest volume
   of trending activity in each country.
   Note: trending_date is stored as YY.DD.MM (e.g., 17.14.11 =
   Nov 14, 2017). SUBSTR(trending_date, 7, 2) extracts characters
   7-8 of this fixed-length string, which corresponds to the
   month portion — not a generic substring trick, it relies on
   this exact date format.
   ------------------------------------------------------------ */
SELECT country, 
SUBSTR(trending_date, 7, 2) AS month,
COUNT(*) AS trend_count
FROM all_videos
GROUP BY country, month
ORDER BY country, trend_count DESC;
/* Result: December (month 12) is the most active trending month
   for DE, GB, and US. India peaks in December as well, while
   Japan's data peaks in March — likely reflecting partial-month
   coverage at the start/end of the dataset window rather than a
   true seasonal pattern (consistent with the Nov/Jun dip seen in
   the Tableau time-series chart). */


/* ------------------------------------------------------------
   QUERY 10: Top 5 Channels with Most Trending Videos
   Purpose: Identify which channels appear most frequently
   across the entire trending dataset, regardless of country.
   ------------------------------------------------------------ */
SELECT channel_title, COUNT(*) AS trending_count
FROM all_videos
GROUP BY channel_title
ORDER BY trending_count DESC
LIMIT 5;
/* Result: Late-night talk shows dominate — The Late Show with
   Stephen Colbert (630), WWE (569), TheEllenShow (529), The
   Tonight Show Starring Jimmy Fallon (515), and Jimmy Kimmel
   Live (509) — reflecting their high-frequency daily upload
   schedule rather than single viral hits. */
