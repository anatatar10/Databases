use Restaurant
go

--create table of versions
--CREATE TABLE Version(Version INT NOT NULL)
--go

--INSERT INTO Version Values(3)
--go


--ADD COLUMN
CREATE OR ALTER PROCEDURE do_proc_1
AS
BEGIN
	ALTER TABLE Customers
	ADD Address varchar(200);

	--modify version
	UPDATE VERSION SET Version = 1;
END;
go

EXEC do_proc_1
go

--DELETE COLUMN
CREATE OR ALTER PROCEDURE undo_proc_1
AS
BEGIN
	ALTER TABLE Customers
	DROP COLUMN Address;
	--modify version
	UPDATE VERSION SET Version = 0;
END;
go

EXEC undo_proc_1
go

--ADD A DEFAULT CONSTRAINT
CREATE OR ALTER PROCEDURE do_proc_2
AS
BEGIN
	ALTER TABLE Customers
	ADD CONSTRAINT DF_Customers DEFAULT 'Cluj' FOR Address;
	UPDATE VERSION SET Version = 2;
END;
go

EXEC do_proc_2
GO

---DELETE A DEFAULT CONSTRAINT
CREATE OR ALTER PROCEDURE undo_proc_2
AS
BEGIN
	ALTER TABLE Customers
	DROP CONSTRAINT DF_Customers; 
	UPDATE VERSION SET Version = 1;
END;
GO

EXEC undo_proc_2
GO


--CREATE A TABLE
CREATE OR ALTER PROCEDURE do_proc_3
AS
BEGIN
	CREATE TABLE Waiters(
	WaiterId INT PRIMARY KEY IDENTITY,
	WaiterName varchar(200),
	WaiterAge INT NOT NULL,
	OID INT NOT NULL
	);
	UPDATE VERSION SET Version = 3;
END
go

EXEC do_proc_3
go

--DELETE A TABLE
CREATE OR ALTER PROCEDURE undo_proc_3
AS
BEGIN
	DROP TABLE Waiters
	UPDATE VERSION SET Version = 2;
END
go

EXEC undo_proc_3
go

--ADD A FOREIGN KEY
CREATE OR ALTER PROCEDURE do_proc_4
AS
BEGIN
	ALTER TABLE Waiters
	ADD CONSTRAINT FK_WaitersOrders
	FOREIGN KEY (OID) REFERENCES Orders(OID)
	UPDATE VERSION SET Version = 4;
END
go

EXEC do_proc_4
go

--DELETE A FOREIGN KEY
CREATE OR ALTER PROCEDURE undo_proc_4
AS
BEGIN
	ALTER TABLE Waiters
	DROP FK_WaitersOrders

	UPDATE VERSION SET Version = 3;
END
go

EXEC undo_proc_4
go

CREATE OR ALTER PROCEDURE goToVersion @versionToGo INT
AS
BEGIN
	DECLARE @currentVersion INT;

	--get current version
	SELECT @currentVersion = Version from VERSION;

	IF(isnumeric(@versionToGo)=0)
	BEGIN
		RAISERROR('Incorrect input, please write an integer',16,1)
		return -1
	END
	ELSE IF(@versionToGo < 1 or @versionToGo > 5)
		BEGIN
			RAISERROR('input needs to be between 1 and 5', 16, 1)
			return -1
		END
	ELSE IF(@versionToGo = @currentVersion)
		BEGIN
			PRINT('The input version is the current one')
			RETURN -1
		END
	ELSE
	BEGIN
	--do procedures
		WHILE(@currentVersion < @versionToGo)
		BEGIN
			SELECT @currentVersion = Version from VERSION;

			IF @currentVersion = 0
			BEGIN
				EXEC do_proc_1
			END
			IF @currentVersion = 1
			BEGIN
				EXEC do_proc_2
			END
			IF @currentVersion = 2
			BEGIN
				EXEC do_proc_3
			END
			IF @currentVersion = 3
			BEGIN
				EXEC do_proc_4
			END

			SELECT @currentVersion = Version from VERSION;
		END

		--redo procedures
		WHILE(@currentVersion > @versionToGo)
		BEGIN
			SELECT @currentVersion = Version from VERSION;

			IF @currentVersion = 1
			BEGIN
				EXEC undo_proc_1
			END
			IF @currentVersion = 2
			BEGIN
				EXEC undo_proc_2
			END
			IF @currentVersion = 3
			BEGIN
				EXEC undo_proc_3
			END
			IF @currentVersion = 4
			BEGIN
				EXEC undo_proc_4
			END

			SELECT @currentVersion = Version from VERSION;
		END
	END
END
go


select* from Version
go
EXEC goToVersion 1
go
select* from Version
go

