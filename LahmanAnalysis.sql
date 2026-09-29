/*
    Lahman Baseball Database - Baseball Rabbit Hole Queries
    --------------------------------------------------------
    SQL Server / T-SQL

    Purpose:
      A collection of reusable, niche baseball-history queries using the
      Lahman Baseball Database. The script starts by creating a normalized
      batting view and then runs a series of exploratory analyses.

    Assumptions:
      - Database name: Lahman2025
      - Tables are in dbo schema
      - The Lahman tables have already been populated
*/

USE [Lahman2025];
GO

SET NOCOUNT ON;
GO

/* ================================================================
   1. REUSABLE PLAYER BATTING VIEW
   ================================================================ */

CREATE OR ALTER VIEW dbo.vw_PlayerBatting
AS
SELECT
    p.playerID,
    CONCAT(p.nameFirst, ' ', p.nameLast) AS PlayerName,
    p.nameFirst,
    p.nameLast,
    p.birthYear,
    p.birthMonth,
    p.birthDay,
    p.birthCity,
    p.birthState,
    p.birthCountry,
    b.yearID,
    b.stint,
    b.teamID,
    b.lgID,
    ISNULL(b.G, 0) AS G,
    ISNULL(b.AB, 0) AS AB,
    ISNULL(b.R, 0) AS R,
    ISNULL(b.H, 0) AS H,
    ISNULL(b.[2B], 0) AS Doubles,
    ISNULL(b.[3B], 0) AS Triples,
    ISNULL(b.HR, 0) AS HR,
    ISNULL(b.RBI, 0) AS RBI,
    ISNULL(b.SB, 0) AS SB,
    ISNULL(b.CS, 0) AS CS,
    ISNULL(b.BB, 0) AS BB,
    ISNULL(b.SO, 0) AS SO
FROM dbo.people AS p
INNER JOIN dbo.batting AS b
    ON p.playerID = b.playerID;
GO

/* ================================================================
   2. HOME RUNS BY PLAYERS BORN IN NORTH CAROLINA
   ================================================================ */

SELECT TOP(100)
    playerID,
    PlayerName,
    birthCity,
    birthState,
    birthYear,
    SUM(HR) AS CareerHomeRuns,
    SUM(H) AS CareerHits,
    SUM(R) AS CareerRuns,
    SUM(RBI) AS CareerRBI
FROM dbo.vw_PlayerBatting
WHERE birthState = 'NC'
GROUP BY
    playerID,
    PlayerName,
    birthCity,
    birthState,
    birthYear
ORDER BY CareerHomeRuns DESC;

/* ================================================================
   3. BIGGEST SINGLE-SEASON HR TOTALS BY NC-BORN PLAYERS
   ================================================================ */

SELECT TOP (50)
    playerID,
    PlayerName,
    yearID AS Season,
    birthCity,
    SUM(HR) AS HomeRuns,
    SUM(AB) AS AtBats,
    SUM(H) AS Hits
FROM dbo.vw_PlayerBatting
WHERE birthState = 'NC'
GROUP BY
    playerID,
    PlayerName,
    yearID,
    birthCity
ORDER BY HomeRuns DESC, Season;

/* ================================================================
   4. STATES THAT HAVE PRODUCED THE MOST MLB HOME RUNS
   ================================================================ */

SELECT
    birthState AS State,
    COUNT(DISTINCT playerID) AS Players,
    SUM(HR) AS TotalHomeRuns,
    SUM(H) AS TotalHits,
    SUM(R) AS TotalRuns,
    SUM(RBI) AS TotalRBI
FROM dbo.vw_PlayerBatting
WHERE birthCountry = 'USA'
  AND birthState IS NOT NULL
GROUP BY birthState
ORDER BY TotalHomeRuns DESC;

/* ================================================================
   5. NORTH CAROLINA CITIES THAT HAVE PRODUCED THE MOST HR
   ================================================================ */

SELECT
    birthCity AS City,
    COUNT(DISTINCT playerID) AS MLBPlayers,
    SUM(HR) AS HomeRuns,
    SUM(H) AS Hits
FROM dbo.vw_PlayerBatting
WHERE birthState = 'NC'
  AND birthCity IS NOT NULL
GROUP BY birthCity
ORDER BY HomeRuns DESC;

/* ================================================================
   6. NORTH CAROLINA CITIES WITH THE MOST MLB PLAYERS
   ================================================================ */

SELECT
    birthCity AS City,
    COUNT(DISTINCT playerID) AS MLBPlayers,
    SUM(HR) AS CareerHR,
    SUM(H) AS CareerHits
FROM dbo.vw_PlayerBatting
WHERE birthState = 'NC'
  AND birthCity IS NOT NULL
GROUP BY birthCity
ORDER BY MLBPlayers DESC, CareerHR DESC;

/* ================================================================
   7. 40+ HR SEASONS
   ================================================================ */

SELECT
    playerID,
    PlayerName,
    yearID AS Season,
    birthCity,
    birthState,
    SUM(HR) AS HR
FROM dbo.vw_PlayerBatting
GROUP BY
    playerID,
    PlayerName,
    yearID,
    birthCity,
    birthState
HAVING SUM(HR) >= 40
ORDER BY HR DESC, Season;

/* ================================================================
   8. 30+ HR SEASONS WITH A SUB-.250 BATTING AVERAGE
   ================================================================ */

SELECT
    playerID,
    PlayerName,
    yearID AS Season,
    SUM(HR) AS HR,
    SUM(H) AS Hits,
    SUM(AB) AS AtBats,
    CAST(SUM(H) AS FLOAT) / NULLIF(SUM(AB), 0) AS BattingAverage
FROM dbo.vw_PlayerBatting
GROUP BY
    playerID,
    PlayerName,
    yearID
HAVING SUM(HR) >= 30
   AND CAST(SUM(H) AS FLOAT) / NULLIF(SUM(AB), 0) < 0.250
ORDER BY HR DESC, BattingAverage;

/* ================================================================
   9. 20+ HR SEASONS WITH A .300+ BATTING AVERAGE
   ================================================================ */

SELECT
    playerID,
    PlayerName,
    yearID AS Season,
    SUM(HR) AS HR,
    SUM(H) AS Hits,
    SUM(AB) AS AtBats,
    CAST(SUM(H) AS FLOAT) / NULLIF(SUM(AB), 0) AS BattingAverage
FROM dbo.vw_PlayerBatting
GROUP BY
    playerID,
    PlayerName,
    yearID
HAVING SUM(HR) >= 20
   AND CAST(SUM(H) AS FLOAT) / NULLIF(SUM(AB), 0) >= 0.300
ORDER BY BattingAverage DESC, HR DESC;

/* ================================================================
   10. PLAYERS WITH MORE CAREER HR THAN TRIPLES
   ================================================================ */

SELECT
    playerID,
    PlayerName,
    SUM(HR) AS HR,
    SUM(Triples) AS Triples,
    SUM(Doubles) AS Doubles,
    SUM(H) AS Hits
FROM dbo.vw_PlayerBatting
GROUP BY
    playerID,
    PlayerName
HAVING SUM(HR) > SUM(Triples)
ORDER BY HR DESC;

/* ================================================================
   11. PLAYERS WITH MORE CAREER TRIPLES THAN HR
   ================================================================ */

SELECT
    playerID,
    PlayerName,
    SUM(Triples) AS Triples,
    SUM(HR) AS HR,
    SUM(Doubles) AS Doubles,
    SUM(H) AS Hits
FROM dbo.vw_PlayerBatting
GROUP BY
    playerID,
    PlayerName
HAVING SUM(Triples) > SUM(HR)
ORDER BY Triples DESC;

/* ================================================================
   12. OLDEST PLAYER-SEASONS WITH A HOME RUN

   Approximate age is based on year only because this analysis does not
   require a game/date-level birth-date calculation.
   ================================================================ */

SELECT TOP (50)
    playerID,
    PlayerName,
    yearID AS Season,
    birthYear,
    yearID - birthYear AS ApproxAge,
    SUM(HR) AS HR
FROM dbo.vw_PlayerBatting
WHERE birthYear IS NOT NULL
GROUP BY
    playerID,
    PlayerName,
    yearID,
    birthYear
HAVING SUM(HR) > 0
ORDER BY ApproxAge DESC, HR DESC;

/* ================================================================
   13. PLAYERS WHO PLAYED FOR THE MOST DIFFERENT TEAMS
   ================================================================ */

SELECT TOP (50)
    playerID,
    PlayerName,
    COUNT(DISTINCT teamID) AS DifferentTeams,
    MIN(yearID) AS FirstSeason,
    MAX(yearID) AS LastSeason,
    SUM(HR) AS HR,
    SUM(H) AS Hits
FROM dbo.vw_PlayerBatting
GROUP BY
    playerID,
    PlayerName
ORDER BY DifferentTeams DESC, LastSeason DESC;

/* ================================================================
   14. PLAYERS WHO HIT HR FOR THE MOST DIFFERENT TEAMS
   ================================================================ */

SELECT TOP (50)
    playerID,
    PlayerName,
    COUNT(DISTINCT teamID) AS TeamsWithHR,
    SUM(HR) AS CareerHR
FROM dbo.vw_PlayerBatting
WHERE HR > 0
GROUP BY
    playerID,
    PlayerName
ORDER BY TeamsWithHR DESC, CareerHR DESC;

/* ================================================================
   15. CAREER POWER PROFILE

   Minimum of 1,000 at-bats removes tiny-sample-size players.
   HRPercentage = HR / AB * 100.
   ================================================================ */

SELECT TOP (100)
    playerID,
    PlayerName,
    birthCity,
    birthState,
    birthCountry,
    MIN(yearID) AS FirstYear,
    MAX(yearID) AS LastYear,
    COUNT(DISTINCT yearID) AS Seasons,
    COUNT(DISTINCT teamID) AS Teams,
    SUM(AB) AS AB,
    SUM(R) AS Runs,
    SUM(H) AS Hits,
    SUM(Doubles) AS Doubles,
    SUM(Triples) AS Triples,
    SUM(HR) AS HR,
    SUM(RBI) AS RBI,
    SUM(SB) AS SB,
    SUM(CS) AS CS,
    SUM(BB) AS Walks,
    SUM(SO) AS Strikeouts,
    CAST(SUM(H) AS FLOAT) / NULLIF(SUM(AB), 0) AS BattingAverage,
    CAST(SUM(HR) AS FLOAT) / NULLIF(SUM(AB), 0) * 100 AS HRPercentage
FROM dbo.vw_PlayerBatting
GROUP BY
    playerID,
    PlayerName,
    birthCity,
    birthState,
    birthCountry
HAVING SUM(AB) >= 1000
ORDER BY HRPercentage DESC;

/* ================================================================
   16. NC-BORN PLAYERS WITH 100+ CAREER HR
   ================================================================ */

SELECT
    PlayerName,
    birthCity,
    SUM(HR) AS HR
FROM dbo.vw_PlayerBatting
WHERE birthState = 'NC'
GROUP BY
    PlayerName,
    birthCity
HAVING SUM(HR) >= 100
ORDER BY HR DESC;

/* ================================================================
   17. NC-BORN PLAYERS WITH 1,000+ CAREER HITS
   ================================================================ */

SELECT
    PlayerName,
    birthCity,
    SUM(H) AS Hits
FROM dbo.vw_PlayerBatting
WHERE birthState = 'NC'
GROUP BY
    PlayerName,
    birthCity
HAVING SUM(H) >= 1000
ORDER BY Hits DESC;

/* ================================================================
   18. NC-BORN PLAYERS WITH MORE SB THAN HR
   ================================================================ */

SELECT
    PlayerName,
    birthCity,
    SUM(SB) AS StolenBases,
    SUM(HR) AS HomeRuns
FROM dbo.vw_PlayerBatting
WHERE birthState = 'NC'
GROUP BY
    PlayerName,
    birthCity
HAVING SUM(SB) > SUM(HR)
ORDER BY StolenBases DESC;

/* ================================================================
   19. HIGH-POWER / LOW-AVERAGE PLAYER-SEASONS
   ================================================================ */

SELECT TOP (100)
    PlayerName,
    yearID AS Season,
    SUM(AB) AS AB,
    SUM(H) AS Hits,
    SUM(HR) AS HR,
    SUM(BB) AS Walks,
    SUM(SO) AS Strikeouts,
    CAST(SUM(H) AS FLOAT) / NULLIF(SUM(AB), 0) AS BattingAverage,
    CAST(SUM(HR) AS FLOAT) / NULLIF(SUM(AB), 0) * 100 AS HRPercentage
FROM dbo.vw_PlayerBatting
GROUP BY
    PlayerName,
    yearID
HAVING SUM(AB) >= 400
   AND SUM(HR) >= 25
ORDER BY HRPercentage DESC;

/* ================================================================
   20. THE "WEIRD BASEBALL" PLAYER PROFILE

   Finds players with unusual combinations of longevity, power,
   speed, and team movement.
   ================================================================ */

SELECT TOP (100)
    playerID,
    PlayerName,
    birthCity,
    birthState,
    MIN(yearID) AS FirstYear,
    MAX(yearID) AS LastYear,
    COUNT(DISTINCT yearID) AS Seasons,
    COUNT(DISTINCT teamID) AS Teams,
    SUM(H) AS Hits,
    SUM(HR) AS HR,
    SUM(Triples) AS Triples,
    SUM(SB) AS SB,
    SUM(RBI) AS RBI,
    SUM(BB) AS Walks,
    SUM(SO) AS Strikeouts,
    CAST(SUM(H) AS FLOAT) / NULLIF(SUM(AB), 0) AS BattingAverage
FROM dbo.vw_PlayerBatting
GROUP BY
    playerID,
    PlayerName,
    birthCity,
    birthState
HAVING SUM(AB) >= 1000
ORDER BY
    COUNT(DISTINCT teamID) DESC,
    COUNT(DISTINCT yearID) DESC,
    SUM(HR) DESC;

/* ================================================================
   END
   ================================================================ */
