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

SELECT COUNT(*) FROM all_videos;

---Top 3 Most Viewed Videos from Top 3 Countries---
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

---Top 3 Trending Categories by Country---
SELECT country,category_id, trending_count
FROM (
    SELECT country, category_id, COUNT(*) AS trending_count,
    ROW_NUMBER() OVER (PARTITION BY country ORDER BY COUNT(*) DESC) AS rank
    FROM all_videos
    GROUP BY country, category_id
)
WHERE rank <= 3;

---Average Views and Likes by Country---
SELECT country, round(AVG(views),2) AS avg_views, round(AVG(likes),2) AS avg_likes
FROM all_videos
GROUP BY country;

---Videos Trending Across Multiple Countries---
SELECT title, COUNT(DISTINCT country) AS country_count
FROM all_videos
GROUP BY title
HAVING country_count > 1
ORDER BY country_count DESC
LIMIT 10;

---Like to Dislike Ratio by Country---
SELECT country, round(AVG(likes * 1.0 / dislikes),2) AS avg_like_dislike_ratio
FROM all_videos
WHERE dislikes > 0
GROUP BY country
ORDER BY avg_like_dislike_ratio DESC;

---Most Commented Videos by Country---
SELECT country, title, max_comments
FROM (
    SELECT country, title, MAX(comment_count) AS max_comments,
    ROW_NUMBER() OVER (PARTITION BY country ORDER BY MAX(comment_count) DESC) AS rank
    FROM all_videos
    GROUP BY country, title
)
WHERE rank <= 3;

---Most Controversial Videos (High Views, Low Likes)---
SELECT title, country, MAX(views) AS max_views, MAX(likes) AS max_likes,
(MAX(likes) * 1.0 / MAX(views)) AS like_rate
FROM all_videos
WHERE views > 1000000
AND likes > 0
GROUP BY title, country
ORDER BY like_rate ASC
LIMIT 10;

---Total Unique Trending Videos by Country---
SELECT country, COUNT(DISTINCT title) AS unique_videos
FROM all_videos
GROUP BY country
ORDER BY unique_videos DESC;

---Most Active Trending Month by Country---
SELECT country, 
SUBSTR(trending_date, 7, 2) AS month,
COUNT(*) AS trend_count
FROM all_videos
GROUP BY country, month
ORDER BY country, trend_count DESC;

---Top 5 Channels with Most Trending Videos---
SELECT channel_title, COUNT(*) AS trending_count
FROM all_videos
GROUP BY channel_title
ORDER BY trending_count DESC
LIMIT 5;