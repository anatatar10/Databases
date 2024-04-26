use Restaurant
go

--a)
-- 1 user-defined function to validate certain parameters.

CREATE FUNCTION checkEmail(@email varchar(50))
RETURNS BIT
AS 
BEGIN
	DECLARE @b BIT
	IF @email LIKE '%@%'
		SET @b = 1
	ELSE
		SET @b = 0
	RETURN @b
END
GO

--stored procedure for the INSERT operation on 2 tables in 1-n relationship
CREATE OR ALTER PROCEDURE addCustomersAndOrders
	@FirstName varchar(50),
    @LastName varchar(50),
    @Email varchar(100),
    @Phone varchar(11),
    @OrderDate DATE,
    @TotalAmount DECIMAL(20,2),
    @PaymentMethod varchar(10)
AS
BEGIN
	DECLARE @CID INT;

	--Validate Email using the user-defined function
	IF dbo.checkEmail(@Email) = 1
	BEGIN
		INSERT INTO Customers(FirstName,LastName,Email,Phone)
		VALUES(@FirstName, @LastName, @Email, @Phone);

		--Get the id of the add customer
		SET @CID = SCOPE_IDENTITY();

		--Add a new order with the obtained CID
		INSERT INTO Orders(OrderDate,TotalAmount,PaymentMethod,CID)
		VALUES(@OrderDate,@TotalAmount,@PaymentMethod,@CID);

		PRINT 'Customer and Order added successfully';

	END
	ELSE
	BEGIN
		PRINT 'Email is not valid. Please provide a valid email address.';
	END
END
GO

EXEC addCustomersAndOrders
	'Charles',
	'Leclerc',
	'charles@ferrari.com',
	16161616,
	'2024-06-16',
	126.16,
	'card'

select * from Customers
select * from Orders

--b)
--show coresponding to each customer, the order date, total amount and item names
CREATE VIEW customersOrders
AS
	SELECT c.FirstName, c.LastName, o.OrderDate, o.TotalAmount, m.ItemName
	FROM Customers c INNER JOIN Orders o on c.CID = o.OID
	INNER JOIN MenuItems m on m.MID = o.OID
GO

select * from customersOrders

--c)
CREATE TABLE Logs
(
	LID INT PRIMARY KEY IDENTITY(1,1),
	TriggerDate DATETIME,
	TriggerType VARCHAR(20),
	NameAffectedTable VARCHAR(50),
	NoAMDRows INT
);

GO

--Create a trigger for table Customers
CREATE OR ALTER TRIGGER LogsChanges
ON Customers
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	DECLARE @TriggerType VARCHAR(20);

	IF EXISTS(SELECT * FROM inserted)
	BEGIN
		IF EXISTS(SELECT * FROM deleted)
			SET @TriggerType = 'UPDATE';
		ELSE
			SET @TriggerType = 'INSERT';
	END
	ELSE
		SET @TriggerType = 'DELTE';

	DECLARE @NoAMDRows INT;

	IF @TriggerType = 'UPDATE'
		SET @NoAMDRows = (SELECT COUNT(*) FROM inserted);
    ELSE
		SET @NoAMDRows = (SELECT ISNULL(COUNT(*),0) FROM inserted) + (SELECT ISNULL(COUNT(*),0) FROM deleted);

	INSERT INTO Logs(TriggerDate, TriggerType, NameAffectedTable, NoAMDRows)
	VALUES(GETDATE(), @TriggerType, 'Customers', @NoAMDRows);
END;
GO

UPDATE CUSTOMERS
SET Email = Email
WHERE FirstName = 'Ana'
GO

SELECT * FROM Logs

INSERT INTO Customers
VALUES('Simona','Halep','simona@tennis.com',123123,'Constanta')
GO

SELECT * FROM Logs

DELETE FROM Customers
WHERE FirstName = 'Simona'

--d)
--Query with clustered index seek and nonclustered index scan
SELECT * FROM Customers WHERE CID = 1 ORDER BY FirstName;

--Show customers whose orders are from a giving date and the price is grater than a value
SELECT 
    Customers.FirstName,
    Customers.LastName,
    Orders.OrderDate,
    Orders.TotalAmount,
    MenuItems.ItemName,
    MenuItems.Price
FROM 
    Customers
JOIN 
    Orders ON Customers.CID = Orders.CID
JOIN 
    OrdersMenuItems ON Orders.OID = OrdersMenuItems.OID
JOIN 
    MenuItems ON OrdersMenuItems.MID = MenuItems.MID
WHERE 
    Orders.OrderDate >= '2023-01-01'
    AND MenuItems.Price > 10.00
ORDER BY 
    Customers.LastName, Orders.OrderDate;
