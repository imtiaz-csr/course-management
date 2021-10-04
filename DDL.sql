CREATE DATABASE coursedb
GO
ALTER DATABASE coursedb
SET COMPATIBILITY_LEVEL =  130
GO
USE coursedb
GO
CREATE TABLE techsubjects
(
	subjectid INT IDENTITY PRIMARY KEY,
	technology NVARCHAR(50) not null
)
GO
CREATE TABLE instructors
(
	instructorid INT IDENTITY PRIMARY KEY,
	instructorname NVARCHAR(50) not null,
	email NVARCHAR(50) not null,
	phone NVARCHAR(25) not null
)
GO
CREATE TABLE courses
(
	courseid INT IDENTITY PRIMARY KEY,
	title NVARCHAR(150) not null,
	totalclass INT not null,
	weeklyclass INT not null,
	classduration INT not null,
	fee MONEY not null,
	instructorid INT not null REFERENCES instructors (instructorid)
)
GO
CREATE TABLE instructorsubjects
(
	instructorid INT not null REFERENCES instructors (instructorid),
	subjectid INT not null REFERENCES techsubjects (subjectid),
	PRIMARY KEY (instructorid,subjectid)
)
GO
CREATE TABLE [batches]
(
	batchid INT IDENTITY PRIMARY KEY,
	startdate DATE not null,
	courseid INT not null REFERENCES courses (courseid)
)
GO
CREATE TABLE students
(
	studentid INT IDENTITY PRIMARY KEY,
	studentname NVARCHAR(30) not null,
	phone NVARCHAR(25) not null,
	batchid INT not null REFERENCES [batches] (batchid)
)
GO
--procedure to insert instructor
CREATE PROCEDURE spinsertInstructor @instructorname NVARCHAR(50),
	@email NVARCHAR(50),
	@phone NVARCHAR(25),
	@subjecids NVARCHAR(1000)
AS
	INSERT INTO instructors (instructorname, phone, email)
	VALUES (@instructorname, @phone, @email)
	--get new IDENTITY VALUE
	DECLARE @id INT = SCOPE_IDENTITY()
	--insert to instructorsubjects
	INSERT INTO instructorsubjects(instructorid, subjectid)
	SELECT @id,RTRIM(LTRIM(VALUE)) AS VALUE FROM string_split(@subjecids, ',')
GO
--trigger prevent more than 15 student per batch
CREATE TRIGGER trPreventOverStudent
ON students 
AFTER INSERT
AS
BEGIN
	DECLARE @bid INT, @count INT
	SELECT @bid = batchid FROM inserted
	SELECT @count = count(*) FROM students WHERE batchid = @bid
	IF @count > 15
	BEGIN
		ROLLBACK TRANSACTION
		;
		THROW 50001, 'Already 15 students enrolled in the batch',  1
	END

END
GO
CREATE FUNCTION getStudentListCSV(@batchid INT) RETURNS NVARCHAR(max)
BEGIN
	DECLARE @x NVARCHAR(2000)
	SET @x= (SELECT  RTRIM(LTRIM(s.studentname)) + ', ' AS 'data()' 
	FROM [batches] b
	INNER JOIN students s ON b.batchid = s.batchid
	WHERE b.batchid = 1
	FOR XML PATH(''))
	
	SET @x= RTRIM(@x)
	SET @x =LEFT(@x, LEN(@x)-1)
	RETURN @x
END
GO
CREATE FUNCTION batchInfo(@batchid INT ) RETURNS TABLE
AS
RETURN (
	SELECT  b.batchid, b.startdate, dbo.getStudentListCSV(@batchid) AS 'students'
	FROM [batches] b
	WHERE batchid = @batchid
)
GO
CREATE FUNCTION fnPagedStudentList(@batchid INT, @page INT, @perpage INT) RETURNS TABLE
AS
RETURN (
	SELECT *
	FROM students
	WHERE batchid = @batchid
	ORDER BY studentid
	offset (@page-1)*@perpage ROWS
	FETCH NEXT @perpage ROWS only
)
GO