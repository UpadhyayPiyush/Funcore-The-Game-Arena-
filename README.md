# Funcore: The Game Arena 

## Overview 

This project focuses on analyzing user gameplay behavior across 20+ online games using SQL and Power BI. Complex SQL queries (25+) were written to extract insights such as game popularity, user engagement trends, top performers, and session patterns. A multi-page Power BI dashboard was developed with slicers, filters, and tooltips for interactive and visually rich storytelling.

## Schema Strucutre 

``` sql
#Creating Users table
CREATE TABLE Users (
    UserID INT PRIMARY KEY,
    Username VARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL,
    JoinDate DATE,
    TotalPlayTime INT,
    Gender VARCHAR(10) NOT NULL,
    Age INT
);


#Creating Games table
CREATE TABLE Games (
    GameID INT PRIMARY KEY,
    GameName VARCHAR(100) NOT NULL,
    Category VARCHAR(50),
    IsMultiplayer BOOLEAN
);


#Creating UserLeaderBoar[d table
CREATE TABLE UserLeaderBoard (
    UserLeaderboardID INT PRIMARY KEY,
    UserID INT,
    HighestScore INT,
    MostPlayedGame VARCHAR(100),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

#Creating GameSession table
CREATE TABLE GameSession (
    SessionID INT PRIMARY KEY,
    UserID INT,
    GameID INT,
    StartTime DATETIME,
    EndTime DATETIME,
    Score INT,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (GameID) REFERENCES Games(GameID)
);
```
## Demo
https://github.com/UpadhyayPiyush/Funcore-The-Game-Arena-/blob/main/snapshot%20.png

## Conclusion 
The project demonstrates how structured gameplay data can be transformed into actionable insights using SQL and Power BI. By leveraging advanced visualizations and interactive features, the final dashboard helps identify trends, highlight user performance, and support data-driven decision-making in the gaming environment.
