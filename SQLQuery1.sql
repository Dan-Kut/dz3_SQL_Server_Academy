USE master;

DROP DATABASE Academy_dz3;

CREATE DATABASE Academy_dz3;

USE Academy_dz3;

CREATE TABLE Curators(
    Id int primary key identity NOT NULL,
	Naame nvarchar(max) NOT NULL,
	Surname nvarchar(max) NOT NULL
);

GO

CREATE TABLE Faculties(
    Id int primary key identity NOT NULL,
	Financing money check(Financing >= 0) default(0) NOT NULL,
	Naame nvarchar(100) unique NOT NULL
);

GO

CREATE TABLE Departments(
    Id int primary key identity NOT NULL,
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

CREATE TABLE Subjects(
    Id int primary key identity NOT NULL,
	Naame nvarchar(100) unique NOT NULL 
);

GO

CREATE TABLE Teachers(
    Id int primary key identity NOT NULL,
	Naame nvarchar(max) NOT NULL,
	Salary money check(Salary > 0) NOT NULL,
	Surname nvarchar(max) NOT NULL
);

GO

CREATE TABLE Lectures(
    Id int primary key identity NOT NULL,
	LectureRoom nvarchar(max) NOT NULL,
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

--1
SELECT T.Surname AS TeacherSurname, G.Naame AS GroupName
FROM Teachers T 
CROSS JOIN Groups G;
--2
SELECT F.Naame FROM Faculties F 
WHERE (
    SELECT SUM(D.Financing)
    FROM Departments D
    WHERE D.FacultyId = F.Id
) > F.Financing;
--3
SELECT  C.Surname AS CuratorSurname, G.Naame AS GroupName
FROM GroupsCurators GC
JOIN Curators C ON C.Id = GC.CuratorId
JOIN Groups G ON G.Id = GC.GroupId;
--4
SELECT DISTINCT T.Surname FROM Groups G
JOIN GroupsLectures GL ON G.Id = GL.GroupId
JOIN Lectures L ON L.Id = GL.LectureId
JOIN Teachers T ON T.Id = L.TeacherId
WHERE G.Naame = 'P107';
--5
SELECT DISTINCT T.Surname, F.Naame AS FacultyName FROM Lectures L
JOIN Teachers T ON T.Id = L.TeacherId
JOIN GroupsLectures GL ON GL.LectureId = L.Id
JOIN Groups G ON G.Id = GL.GroupId
JOIN Departments D ON D.Id = G.DepartmentId
JOIN Faculties F ON F.Id = D.FacultyId;
--6
SELECT D.Naame, G.Naame FROM Groups AS G INNER JOIN Departments AS D ON D.Id = G.DepartmentId
--7
SELECT S.Naame AS [Subject] FROM Teachers AS T
JOIN Lectures L ON L.TeacherId = T.Id
JOIN Subjects S ON S.Id = L.SubjectId
WHERE T.Naame = 'Samantha' AND T.Surname = 'Adams'
--8
SELECT D.Naame AS DepartmentName FROM Subjects S
JOIN Lectures L ON L.SubjectId = S.Id
JOIN GroupsLectures GL ON GL.LectureId = L.Id
JOIN Groups G ON G.Id = GL.GroupId
JOIN Departments D ON D.Id = G.DepartmentId
WHERE S.Naame = 'Теорія баз даних';
--9
SELECT G.Naame AS GroupName
FROM Groups G
JOIN Departments D ON D.Id = G.DepartmentId
JOIN Faculties F ON F.Id = D.FacultyId
WHERE F.Naame = 'Комп''ютерні науки';
--10
SELECT G.Naame AS GroupName, F.Naame AS FacultyName FROM Groups G
JOIN Departments D ON D.Id = G.DepartmentId
JOIN Faculties F ON F.Id = D.FacultyId
WHERE G.Yeaar = 5;
--11
SELECT DISTINCT T.Surname AS TeacherSurname, S.Naame AS SubjectName, G.Naame AS GroupName FROM Lectures L
JOIN Teachers T ON T.Id = L.TeacherId
JOIN Subjects S ON S.Id = L.SubjectId
JOIN GroupsLectures GL ON GL.LectureId = L.Id
JOIN Groups G ON G.Id = GL.GroupId
WHERE L.LectureRoom = 'B103';
