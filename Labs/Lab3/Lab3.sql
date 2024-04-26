
use Formula1  -- Specify the database
go

-- Stored Procedures

--drop table DatabaseVersion

--CREATE TABLE DatabaseVersion
--(
--	Version INT NOT NULL
--);

--GO

--INSERT INTO DatabaseVersion
--VALUES (3)

GO

CREATE OR ALTER PROCEDURE do_1  -- ADD COLUMN
AS
BEGIN 
	ALTER TABLE	Cars
	ADD Colour varchar(50);

	-- Log version
	UPDATE DatabaseVersion SET Version=2;
END;

GO

EXEC do_1

GO

CREATE OR ALTER PROCEDURE undo_1  -- DELETE COLUMN
AS
BEGIN
	ALTER TABLE	Cars
	DROP COLUMN Colour;

	-- Log version
	UPDATE DatabaseVersion SET Version=1;
END;

GO

EXEC undo_1

GO

CREATE OR ALTER PROCEDURE do_2  -- ADD DEFAULT CONSTRAINT
AS
BEGIN
	ALTER TABLE Cars
	ADD CONSTRAINT DF_Colour DEFAULT 'Grey' FOR Colour

	-- Log version
	UPDATE DatabaseVersion SET Version=3;
END;

GO

EXEC do_2

GO

CREATE OR ALTER PROCEDURE undo_2  -- DELETE DEFAULT CONSTRAINT
AS
BEGIN
	ALTER TABLE Cars
	DROP CONSTRAINT DF_Colour;

	-- Log version
	UPDATE DatabaseVersion SET Version=2;
END;

GO

EXEC undo_2

GO


CREATE OR ALTER PROCEDURE do_3  -- ADD TABLE
AS
BEGIN
	CREATE TABLE Sponsors 
	(
	  SponsorsID INT PRIMARY KEY IDENTITY,
	  SponsorName VARCHAR(50) NOT NULL,
	  TeamsID INT NOT NULL
	);

	-- Log version
	UPDATE DatabaseVersion SET Version=4;
END;

GO 

EXEC do_3

GO

CREATE OR ALTER PROCEDURE undo_3  -- DELETE TABLE
AS
BEGIN
	DROP TABLE Sponsors;

	-- Log version
	UPDATE DatabaseVersion SET Version=3;
END;

GO

EXEC undo_3

GO

CREATE OR ALTER  PROCEDURE do_4  -- ADD FOREIGN KEY
AS
BEGIN
	ALTER TABLE Sponsors
	ADD CONSTRAINT FK_SponsorsTeams
	FOREIGN KEY (TeamsID) REFERENCES Teams(TeamsID)

	-- Log version
	UPDATE DatabaseVersion SET Version=5;
END;

GO

EXEC do_4

GO

CREATE OR ALTER PROCEDURE undo_4  -- DELETE FOREIGN KEY
AS
BEGIN
	ALTER TABLE Sponsors
	DROP CONSTRAINT FK_SponsorsTeams;

	-- Log version
	UPDATE DatabaseVersion SET Version=4;
END;

GO

EXEC undo_4

GO


CREATE OR ALTER  PROCEDURE revertToVersion @TargetVersion INT
AS
BEGIN
	DECLARE @CurrentVersion INT;

	-- Get current version
	SELECT @CurrentVersion = Version FROM DatabaseVersion;

		-- Apply each operation
		WHILE @CurrentVersion < @TargetVersion
		BEGIN 
			SELECT @CurrentVersion = Version FROM DatabaseVersion;

			IF @CurrentVersion = 1
			BEGIN
				EXEC do_1;
			END
			ELSE IF @CurrentVersion = 2
			BEGIN
				EXEC do_2;
			END
			ELSE IF @CurrentVersion = 3
			BEGIN
				EXEC do_3;
			END
			ELSE IF @CurrentVersion = 4
			BEGIN
				EXEC do_4;
			END

			-- UPDATE @CurrentVersion
		
			SELECT @CurrentVersion = Version FROM DatabaseVersion;
		END;
		WHILE @CurrentVersion > @TargetVersion
		BEGIN
			SELECT @CurrentVersion = Version FROM DatabaseVersion;
			IF @CurrentVersion = 2
			BEGIN
				EXEC undo_1;
			END
			ELSE IF @CurrentVersion = 3
			BEGIN
				EXEC undo_2;
			END
			ELSE IF @CurrentVersion = 4
			BEGIN
				EXEC undo_3;
			END
			ELSE IF @CurrentVersion = 5
			BEGIN
				EXEC undo_4;
			END
			
			SELECT @CurrentVersion = Version FROM DatabaseVersion;
		END;
END;

GO


EXEC revertToVersion 2;

SELECT * FROM DatabaseVersion
