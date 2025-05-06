### Analyzing Tables 
-- Select * from games;
-- Select * from gamesession;
-- Select * from userleaderboard;
-- Select * from users;

################## Extract Insights from tables ######################

# Q: Find total number of users
-- SELECT COUNT(*) AS TotalUsers
-- FROM Users;


# Q: Number of games 
-- SELECT GameName
-- FROM Games
-- ORDER BY GameName ASC;


# Q: All Multiplayer Games
-- SELECT GameID, GameName
-- FROM Games
-- WHERE IsMultiplayer = TRUE;


# Q: Find total number of sessions played per game
-- SELECT g.GameID, g.GameName, COUNT(gs.SessionID) AS TotalSessions
-- FROM Games g
-- LEFT JOIN GameSession gs ON g.GameID = gs.GameID
-- GROUP BY g.GameID, g.GameName
-- ORDER BY TotalSessions DESC;


# Q: Calculate average score achieved by users in each game
-- SELECT g.GameID, g.GameName, AVG(gs.Score) AS AverageScore
-- FROM Games g
-- JOIN GameSession gs ON g.GameID = gs.GameID
-- GROUP BY g.GameID, g.GameName;


# Q: Top 10 users with the highest total scores (across all sessions).
-- SELECT u.UserID, u.UserName, SUM(gs.Score) AS TotalScore
-- FROM Users u
-- JOIN GameSession gs ON u.UserID = gs.UserID
-- GROUP BY u.UserID, u.UserName
-- ORDER BY TotalScore DESC
-- LIMIT 10;


# Q: Earliest (first) session played date for each user.
-- SELECT UserID, MIN(StartTime) AS FirstSessionDate
-- FROM GameSession
-- GROUP BY UserID;


# Q: Rank users based on their highest score using a window function
-- SELECT 
--   UserID,
--   HighestScore,
--   RANK() OVER (ORDER BY HighestScore DESC) AS Rank_Pos
-- FROM 
--   UserLeaderBoard;

# Q: Top 5 played games 

-- SELECT 
--     gs.GameID,
--     g.GameName,
--     COUNT(*) AS TotalPlayedCount
-- FROM 
--     GameSession gs
-- JOIN 
--     Games g ON gs.GameID = g.GameID
-- GROUP BY 
--     gs.GameID, g.GameName
-- ORDER BY 
--     TotalPlayedCount DESC
-- LIMIT 5;


# Q: Top 5 users with most total sessions played (using CTE and aggregation)
-- WITH UserSessions AS (
--   SELECT 
--     UserID, 
--     COUNT(*) AS TotalSessions
--   FROM 
--     GameSession
--   GROUP BY 
--     UserID
-- )
-- SELECT * 
-- FROM UserSessions
-- ORDER BY TotalSessions DESC
-- Limit 5;


# Q: Each user's first and last game played (start_time ordering)
-- WITH OrderedSessions AS (
--   SELECT 
--     gs.UserID, 
--     gs.GameID,
--     g.GameName,
--     gs.StartTime,
--     ROW_NUMBER() OVER (PARTITION BY gs.UserID ORDER BY gs.StartTime ASC) AS FirstGame,
--     ROW_NUMBER() OVER (PARTITION BY gs.UserID ORDER BY gs.StartTime DESC) AS LastGame
--   FROM 
--     GameSession gs
--   JOIN 
--     Games g ON gs.GameID = g.GameID
-- )

-- SELECT 
--   UserID, 
--   MAX(CASE WHEN FirstGame = 1 THEN GameName END) AS FirstPlayedGameName,
--   MAX(CASE WHEN LastGame = 1 THEN GameName END) AS LastPlayedGameName
-- FROM 
--   OrderedSessions
-- GROUP BY 
--   UserID;


# Q: Count of Users whose highest score is > 2 × average session score
-- WITH AvgSessionScore AS (
--   SELECT 
--     UserID, 
--     AVG(Score) AS AvgScorePerSession
--   FROM 
--     GameSession
--   GROUP BY 
--     UserID
-- )

-- SELECT 
--     COUNT(*) AS UsersCount
-- FROM 
--     userleaderboard ul
-- JOIN 
--     AvgSessionScore avg_s ON ul.UserID = avg_s.UserID
-- WHERE 
--     ul.HighestScore > 2 * avg_s.AvgScorePerSession;

# Q: Users who played only multiplayer games
-- SELECT 
--   DISTINCT u.UserID,
--   u.UserName
-- FROM 
--   GameSession gs
-- JOIN 
--   Games g ON gs.GameID = g.GameID
-- JOIN 
--   Users u ON gs.UserID = u.UserID
-- GROUP BY 
--   u.UserID, u.UserName
-- HAVING 
--   SUM(CASE WHEN g.IsMultiplayer = FALSE THEN 1 ELSE 0 END) = 0;

# Q: Users who improved their scores over time (using LAG)
-- WITH ScoredSessions AS (
--   SELECT 
--     UserID, 
--     StartTime, 
--     Score,
--     LAG(Score) OVER (PARTITION BY UserID ORDER BY StartTime) AS PrevScore
--   FROM 
--     GameSession
-- )
-- SELECT 
--   UserID, 
--   StartTime, 
--   Score, 
--   PrevScore
-- FROM ScoredSessions
-- WHERE PrevScore IS NOT NULL AND Score > PrevScore;

# Q: Session where user achieved their personal best
-- SELECT 
--   gs.*
-- FROM 
--   GameSession gs
-- JOIN 
--   UserLeaderBoard ul ON gs.UserID = ul.UserID
-- WHERE 
--   gs.Score = ul.HighestScore;


# Q:Top 3 games with longest average session duration
-- WITH AvgDuration AS (
--   SELECT 
--     g.GameName,
--     AVG(TIMESTAMPDIFF(SECOND, StartTime, EndTime)) AS AvgSessionDuration
--   FROM 
--     GameSession gs
--   JOIN 
--     Games g ON gs.GameID = g.GameID
--   GROUP BY 
--     g.GameName
-- )
-- SELECT 
--   *
-- FROM (
--   SELECT 
--     *, 
--     ROW_NUMBER() OVER (ORDER BY AvgSessionDuration DESC) AS rnk
--   FROM AvgDuration
-- ) Ranked
-- WHERE rnk <= 3;


# Q:Total time spent by each user
-- SELECT 
--   UserID,
--   SUM(TIMESTAMPDIFF(SECOND, StartTime, EndTime)) AS TotalTimeSpentSec
-- FROM 
--   GameSession
-- GROUP BY 
--   UserID;

# Q:Power users (played >04 sessions and in top 10% highest score)
-- WITH SessionCount AS (
--   SELECT UserID, COUNT(*) AS SessionCount
--   FROM GameSession
--   GROUP BY UserID
-- ),
-- TopScorers AS (
--   SELECT UserID, PERCENT_RANK() OVER (ORDER BY HighestScore DESC) AS ScoreRank
--   FROM UserLeaderBoard
-- )
-- SELECT 
--   sc.UserID
-- FROM 
--   SessionCount sc
-- JOIN 
--   TopScorers ts ON sc.UserID = ts.UserID
-- WHERE 
--   sc.SessionCount > 4 AND ts.ScoreRank <= 0.10;

# Q: Highest average scorer for each game

-- WITH AvgUserGameScore AS (
--   SELECT 
--     GameID, 
--     UserID, 
--     AVG(Score) AS AvgScore
--   FROM 
--     GameSession
--   GROUP BY 
--     GameID, UserID
-- )
-- SELECT 
--   *
-- FROM (
--   SELECT 
--     GameID, UserID, AvgScore,
--     ROW_NUMBER() OVER (PARTITION BY GameID ORDER BY AvgScore DESC) AS rnk
--   FROM AvgUserGameScore
-- ) Ranked
-- WHERE rnk = 1;


# Q: Trend of sessions over time (daily session counts)
-- SELECT 
--   DATE(StartTime) AS SessionDate,
--   COUNT(*) AS SessionsPlayed
-- FROM 
--   GameSession
-- GROUP BY 
--   SessionDate
-- ORDER BY 
--   SessionDate ASC;

# Q: Users who played same game multiple times but never scored above 500
-- SELECT 
--   UserID, 
--   GameID
-- FROM 
--   GameSession
-- GROUP BY 
--   UserID, GameID
-- HAVING 
--   MAX(Score) <= 500 AND COUNT(*) > 1;

# Q: Retention: users played 2nd session within 2 days of first session

-- WITH SessionTimes AS (
--   SELECT 
--     UserID, 
--     StartTime,
--     ROW_NUMBER() OVER (PARTITION BY UserID ORDER BY StartTime) AS SessionOrder
--   FROM 
--     GameSession
-- )

-- SELECT 
--   st1.UserID,
--   u.UserName
-- FROM 
--   SessionTimes st1
-- JOIN 
--   SessionTimes st2 ON st1.UserID = st2.UserID AND st2.SessionOrder = 2
-- JOIN 
--   Users u ON st1.UserID = u.UserID
-- WHERE 
--   st1.SessionOrder = 1
--   AND DATEDIFF(st2.StartTime, st1.StartTime) = 2;


# Q: Median session score for each game
-- WITH ScoreRanks AS (
--   SELECT 
--     GameID, 
--     Score,
--     ROW_NUMBER() OVER (PARTITION BY GameID ORDER BY Score) AS RowAsc,
--     COUNT(*) OVER (PARTITION BY GameID) AS TotalRows
--   FROM 
--     GameSession
-- )
-- SELECT 
--   GameID, 
--   AVG(Score) AS MedianScore
-- FROM 
--   ScoreRanks
-- WHERE 
--   RowAsc IN (FLOOR((TotalRows + 1)/2), CEIL((TotalRows + 1)/2))
-- GROUP BY 
--   GameID;








