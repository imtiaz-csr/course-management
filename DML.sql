USE coursedb
GO
--initial data
INSERT INTO techsubjects VALUES
('HTML5'), ('Website design'),('CSS'), ('Bootstrap'), 
('JavAScript'), ('C#'), ('Angular'), ('React'), ('ASP.NET'), ('MVC'), ('MVC Core')
GO


EXEC spinsertInstructor @instructorname ='Rahmatullah Muzahid',
						@email ='arif@gmail.com',
						@phONe='01710xxxxxx',
						@subjecids ='1,2,3,4'
EXEC spinsertInstructor @instructorname ='Arif Hossain',
						@email ='arif@gmail.com',
						@phONe='01710xxxxxx',
						@subjecids ='9, 10, 11'
EXEC spinsertInstructor @instructorname ='Kamrul Hossain',
						@email ='km@gmail.com',
						@phONe='01710xxxxxx',
						@subjecids ='7, 8'
SELECT * FROM instructors
SELECT * FROM instructorsubjects
GO
INSERT INTO courses( title,totalclass, weeklyclass, classduration, fee, instructorid)
VALUES ('MVC Core 3', 30, 3, 4, 30000.00, 1)
GO
INSERT INTO [batches] (courseid, startdate)
VALUES(1, '2020-10-01')
GO
--test 15 over student
DECLARE @i INT =1
WHILE @i <= 16
BEGIN
	--at @i =16 it fail for TRIGGER
	INSERT INTO students (studentname, phone, batchid)
	VALUES('Student ' + cASt(@i AS VARCHAR), '017120111' +cASt(@i AS VARCHAR), 1)
	SET @i = @i +1
END
GO
--check info function
SELECT * FROM batchInfo(1)
GO
--check paged studentlist function
SELECT * FROM fnPagedStudentList(1, 2, 5)
GO
