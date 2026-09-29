# Lahman Baseball SQL Analysis

A collection of **SQL Server / T-SQL baseball analytics** built on the Lahman Baseball Database.

This project uses the Lahman database to explore MLB history through SQL, with an emphasis on interesting and sometimes niche questions involving player performance, birthplace, geography, power, speed, longevity, and team movement.

## Project Goals

The goal of this project is to demonstrate practical SQL Server skills while exploring real baseball data.

The analyses focus on:

- Joining player biographical information with batting statistics
- Aggregating career and single-season statistics
- Filtering and grouping data
- Calculating derived statistics
- Comparing players, states, and cities
- Identifying unusual statistical combinations
- Using SQL views to simplify repeated analysis
- Turning a large historical dataset into questions that are easy to investigate

---

## Database

This project uses the **Lahman Baseball Database**.

The primary tables used in this analysis are:

- `people` — player biographical information
- `batting` — batting statistics by player, season, team, and stint

Additional Lahman tables can be incorporated for future analyses, including:

- `pitching`
- `fielding`
- `teams`
- `appearances`
- `salaries`
- `halloffame`
- `awardsplayers`
- `allstarfull`
- `managers`
- `schoolsplayers`

The SQL in this repository is written for **Microsoft SQL Server / T-SQL**.

---

## Getting Started

### 1. Restore the Lahman database

Restore the provided SQL Server database backup or otherwise load the Lahman database into SQL Server.

For example, the database can be named:

```sql
Lahman2025
```

### 2. Open the analysis script

Open:

```text
sql/lahman-baseball-rabbit-hole.sql
```

in SQL Server Management Studio (SSMS), Azure Data Studio, or another SQL Server-compatible editor.

### 3. Select the database

The script assumes the Lahman database is named:

```sql
USE Lahman2025;
GO
```

If your database has a different name, change the `USE` statement.

### 4. Run the script

The script first creates a reusable view and then runs a series of independent baseball analyses.

---

# Analysis Included

## 1. North Carolina-Born Players

One of the central questions in this project:

> How many home runs have been hit by MLB players born in North Carolina?

The analysis combines:

```text
people
   ↓
playerID
   ↓
batting
```

and calculates career statistics for players whose `birthState = 'NC'`.

Statistics include:

- Home runs
- Hits
- Runs
- RBI
- Birth city
- Birth year

---

## 2. Best Single-Season HR Performances by NC-Born Players

Instead of looking at career totals, the project identifies individual seasons in which North Carolina-born players hit the most home runs.

This makes it possible to investigate questions such as:

- Which NC-born player had the biggest power season?
- Which seasons stand out historically?
- Did a player's best season represent most of their career production?

---

## 3. Home Runs by Birth State

The project aggregates MLB home runs by the player's U.S. birth state.

This allows questions such as:

> Which states have produced the most MLB home runs?

The analysis also includes:

- Number of MLB players
- Total hits
- Total runs
- Total RBI

This provides a geographic perspective on baseball production.

---

## 4. North Carolina Baseball by City

The project drills down from state to city.

It examines:

- Number of MLB players born in each NC city
- Career home runs from those players
- Career hits from those players

This creates a way to investigate the baseball history of individual North Carolina communities.

---

## 5. 40+ Home Run Seasons

Finds seasons in which a player hit at least 40 home runs.

This is a straightforward example of using:

```sql
GROUP BY
HAVING
ORDER BY
```

to identify exceptional individual seasons.

---

## 6. Power Without Batting Average

Identifies seasons in which players:

- Hit at least 30 home runs
- Had a batting average below .250

This explores a different type of offensive profile: players who produced substantial home-run power without maintaining a high batting average.

---

## 7. Power and Batting Average

Identifies seasons with:

- At least 20 home runs
- A batting average of at least .300

This can be used to investigate seasons combining significant power with a high batting average.

---

## 8. Home Runs vs. Triples

Two analyses compare career home runs and triples.

### More HR than triples

Identifies players whose career home-run totals exceeded their triples.

### More triples than HR

Identifies players whose career triples exceeded their home runs.

The second group is particularly useful for exploring historical playing styles and the differences between eras.

---

## 9. Longevity and Age

The project estimates player age by comparing:

```text
season year - birth year
```

and identifies older player-seasons in which players hit home runs.

This can be used to investigate questions surrounding:

- Career longevity
- Aging
- Late-career power
- Historical differences between eras

The age calculation is intentionally described as approximate because the basic calculation does not account for the player's exact birth date relative to the season date.

---

## 10. Players Who Played for the Most Teams

This analysis counts the number of distinct teams represented in a player's batting records.

It also reports:

- First MLB season
- Last MLB season
- Career home runs
- Career hits

This is useful for investigating player movement and journeyman careers.

---

## 11. Players Who Hit Home Runs for the Most Teams

A more specialized version of the previous analysis.

Instead of simply asking:

> How many teams did this player play for?

it asks:

> How many different teams did this player actually hit a home run for?

This distinguishes simple team appearances from actual offensive production.

---

## 12. Career Home-Run Rate

The project calculates home runs relative to at-bats:

```text
HR / AB × 100
```

A minimum at-bat threshold is used so that players with extremely small samples do not dominate the results.

This is an example of why raw career totals aren't always enough when comparing players.

---

# Reusable View

The project creates:

```sql
dbo.vw_PlayerBatting
```

This view combines player biographical information with batting statistics.

Instead of repeatedly writing:

```sql
FROM people
JOIN batting
    ON people.playerID = batting.playerID
```

future queries can use:

```sql
FROM dbo.vw_PlayerBatting
```

This makes exploratory analysis much faster and easier to read.

---

# Example Queries

After creating the view, a simple North Carolina analysis becomes:

```sql
SELECT
    PlayerName,
    birthCity,
    SUM(HR) AS CareerHR
FROM dbo.vw_PlayerBatting
WHERE birthState = 'NC'
GROUP BY
    PlayerName,
    birthCity
ORDER BY CareerHR DESC;
```

### NC players with 100+ career HR

```sql
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
```

### NC players with 1,000+ career hits

```sql
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
```

### NC players with more stolen bases than home runs

```sql
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
```

---

# SQL Skills Demonstrated

This project demonstrates several practical SQL concepts:

### Data Retrieval

- `SELECT`
- `WHERE`
- `ORDER BY`
- `TOP`

### Joins

- `INNER JOIN`

### Aggregation

- `SUM`
- `COUNT`
- `COUNT(DISTINCT ...)`
- `MIN`
- `MAX`

### Grouping

- `GROUP BY`
- `HAVING`

### Calculated Fields

- Batting average
- Home-run rate
- Approximate player age

### Null Handling

```sql
ISNULL()
NULLIF()
```

### Database Objects

- `CREATE OR ALTER VIEW`

### SQL Server Features

- T-SQL syntax
- `GO`
- SQL Server-compatible data types
- Schema-qualified table/view references

---

# Interesting Questions to Explore

The current script is only the beginning. Some additional questions worth investigating:

### Geography

- Which states produce the most MLB players?
- Which NC cities have produced the most MLB players?
- Which countries have produced the most home runs?
- Which countries produce the highest HR per player?

### Hitting

- Who had the highest single-season HR rate?
- Who had the most career doubles without reaching 100 HR?
- Which players had more triples than home runs?
- Who had the most RBI in a season without hitting 30 HR?
- Who had the most walks in a season with fewer than 10 HR?

### Longevity

- Who played MLB across the greatest number of decades?
- Who hit a home run in the most different decades?
- Who had the longest gap between first and last MLB seasons?

### Team Movement

- Who played for the most franchises?
- Who hit for the most franchises?
- Which players had productive seasons for multiple teams in the same year?

### Historical Baseball

- How did batting averages change by decade?
- How did home-run rates change by decade?
- Which eras produced the most triples?
- Which birth states produced the most players during different eras?

### Unusual Players

- Players with more stolen bases than home runs
- Players with more triples than doubles
- Players with extremely high walk rates
- Players with unusually high strikeout rates
- Players who accumulated significant statistics despite short careers

---

# Potential Future Additions

The project can be expanded beyond batting statistics.

## Pitching Analysis

Using the `pitching` table:

- Career wins
- Strikeout rates
- ERA
- Complete games
- Shutouts
- Pitchers by birthplace
- Pitchers with unusual win/loss records

## Fielding Analysis

Using the `fielding` table:

- Defensive games by position
- Fielding percentage
- Putouts
- Assists
- Errors
- Players who played multiple positions

## Salaries

Using the `salaries` table:

- Salary by era
- Highest-paid players
- Salary vs. performance
- Salary growth over time
- Team payroll trends

## Hall of Fame

Using `halloffame`:

- Hall of Fame players by birthplace
- Hall of Fame players by position
- Hall of Fame career statistics
- Players with similar statistical profiles to Hall of Famers

---

# Why This Project?

Baseball is particularly well suited to SQL because its history is highly structured.

A single player can be connected to:

```text
Player
  ├── Birthplace
  ├── Seasons
  ├── Teams
  ├── Batting
  ├── Pitching
  ├── Fielding
  ├── Awards
  ├── Salary
  └── Hall of Fame
```

That makes the Lahman database a useful dataset for demonstrating how relational databases can answer complex historical questions.

The goal of this project is not simply to find famous baseball records. It is to use SQL to uncover **unexpected patterns and niche relationships hidden inside a large historical dataset**.

---

# Tools

- Microsoft SQL Server
- SQL Server Management Studio (SSMS) or Azure Data Studio
- T-SQL
- Lahman Baseball Database
- Git / GitHub

---
---

# Author

**Chris Collum**

This project was created as a SQL/data analytics portfolio project using historical Major League Baseball data.

