USE master;

DROP DATABASE Academy_dz3;

CREATE DATABASE Academy_dz4;

USE Academy_dz4;

CREATE TABLE Curators(
    Id int primary key identity NOT NULL,
	Naame nvarchar(max) NOT NULL,
	Surname nvarchar(max) NOT NULL
);

GO

CREATE TABLE Faculties(
    Id int primary key identity NOT NULL,
	Naame nvarchar(100) unique NOT NULL
);

GO

CREATE TABLE Departments(
    Id int primary key identity NOT NULL,
	Building int check(1 <= Building AND Building <= 5) NOT NULL,
	Financing money check(Financing >= 0) default(0) NOT NULL,
	Naame nvarchar(100) unique NOT NULL,
	FacultyId int foreign key references Faculties(Id) NOT NULL
);

GO

CREATE TABLE Groups(
    Id int primary key identity NOT NULL,
	Naame nvarchar(10) unique NOT NULL,
	Yeaar int check(1 <= Yeaar AND Yeaar <= 5) NOT NULL,
	DepartmentId int foreign key references Departments(Id) NOT NULL
);

GO

CREATE TABLE Students(
    Id int primary key identity NOT NULL,
	Naame nvarchar(max) NOT NULL,
	Rating int check(0 <= Rating AND Rating <= 5) NOT NULL,
	Surname nvarchar(max) NOT NULL
)

GO

CREATE TABLE Subjects(
    Id int primary key identity NOT NULL,
	Naame nvarchar(100) unique NOT NULL 
);

GO


CREATE TABLE Teachers(
    Id int primary key identity NOT NULL,
	IsProfessor bit default(0) NOT NULL,
	Naame nvarchar(max) NOT NULL,
	Salary money check(Salary > 0) NOT NULL,
	Surname nvarchar(max) NOT NULL
);

GO

CREATE TABLE Lectures(
    Id int primary key identity NOT NULL,
	[Date] date check(Date <= GETDATE()) NOT NULL,
	SubjectId int foreign key references Subjects(Id) NOT NULL,
	TeacherId int foreign key references Teachers(Id) NOT NULL
);

GO

CREATE TABLE GroupsCurators(
    Id int primary key identity NOT NULL,
	CuratorId int foreign key references Curators(Id) NOT NULL,
	GroupId int foreign key references Groups(Id) NOT NULL
);

GO

CREATE TABLE GroupsLectures(
    Id int primary key identity NOT NULL,
	GroupId int foreign key references Groups(Id) NOT NULL,
	LectureId int foreign key references Lectures(Id) NOT NULL
)

GO

CREATE TABLE GroupsStudents(
    Id int primary key identity NOT NULL,
	GroupId int foreign key references Groups(Id) NOT NULL,
	StudentId int foreign key references Students(Id) NOT NULL
)

--1
SELECT D.Building FROM Departments D
GROUP BY D.Building
HAVING SUM(D.Financing) > 100000;
--2
WITH FirstWeek AS (
    SELECT DATEPART(WEEK, MIN(L.Date)) AS WeekNum
    FROM Lectures L
)
SELECT G.Naame AS GroupName FROM Groups G
JOIN Departments D ON D.Id = G.DepartmentId
JOIN GroupsLectures GL ON GL.GroupId = G.Id
JOIN Lectures L ON L.Id = GL.LectureId
CROSS JOIN FirstWeek F
WHERE G.Yeaar = 5 AND D.Naame = 'Software Development' AND DATEPART(WEEK, L.[Date]) = F.WeekNum
GROUP BY G.Naame
HAVING COUNT(*) > 10;
--3
WITH AvgRatings AS (SELECT G.Id, G.Naame, AVG(S.Rating) AS AvgRating FROM GroupsStudents GS
JOIN Groups G ON G.Id = GS.GroupId
JOIN Students S ON S.Id = GS.StudentId
GROUP BY G.Id, G.Naame
)
SELECT AR.Naame FROM AvgRatings AR
WHERE AR.AvgRating > (
    SELECT AvgRating
    FROM AvgRatings
    WHERE Naame = 'D221'
);
--4
SELECT T.Surname, T.Naame FROM Teachers T
WHERE T.Salary > (
    SELECT AVG(T2.Salary)
    FROM Teachers T2
    WHERE T2.IsProfessor = 1
);
--5
SELECT G.Naame FROM GroupsCurators GC
JOIN Groups G ON G.Id = GC.GroupId
GROUP BY G.Naame
HAVING COUNT(*) > 1;
--6
WITH GroupAvg AS (SELECT G.Id, G.Naame, AVG(S.Rating) AS AvgRating, G.Yeaar FROM GroupsStudents GS
JOIN Groups G ON G.Id = GS.GroupId
JOIN Students S ON S.Id = GS.StudentId
GROUP BY G.Id, G.Naame, G.Yeaar
),
Min5th AS (SELECT MIN(AvgRating) AS MinRating5 FROM GroupAvg
WHERE Yeaar = 5
)
SELECT GA.Naame FROM GroupAvg GA
CROSS JOIN Min5th M
WHERE GA.AvgRating < M.MinRating5;
--7
WITH FacultyFunds AS (SELECT F.Id, F.Naame, SUM(D.Financing) AS TotalDeptFin FROM Faculties F
JOIN Departments D ON D.FacultyId = F.Id
GROUP BY F.Id, F.Naame
),
CS_Fund AS (SELECT TotalDeptFin AS CSFund FROM FacultyFunds
WHERE Naame = 'Computer Science'
)
SELECT FF.Naame FROM FacultyFunds FF
CROSS JOIN CS_Fund C
WHERE FF.TotalDeptFin > C.CSFund;
--8 A litle didn't understand this SELECT
SELECT T.Naame, T.Surname, S.Naame FROM Teachers T
JOIN Lectures L ON L.TeacherId = T.Id
JOIN Subjects S ON S.Id = L.SubjectId
--9
SELECT TOP 1 S.Naame FROM Subjects S
JOIN Lectures L ON L.SubjectId = S.Id
GROUP BY S.Naame
ORDER BY COUNT(*) ASC;
--10
SELECT COUNT(DISTINCT GS.StudentId) AS StudentCount, COUNT(DISTINCT L.SubjectId) AS SubjectCount FROM Departments D
LEFT JOIN Groups G ON G.DepartmentId = D.Id
LEFT JOIN GroupsStudents GS ON GS.GroupId = G.Id
LEFT JOIN GroupsLectures GL ON GL.GroupId = G.Id
LEFT JOIN Lectures L ON L.Id = GL.LectureId
WHERE D.Naame = 'Software Development';