use Restaurant
go

CREATE TABLE Customers (
	CID INT PRIMARY KEY identity NOT NULL,
	FirstName varchar(50),
	LastName varchar(50),
	Email varchar(100),
	Phone varchar(11)
);
go

CREATE TABLE Orders (
	OID INT PRIMARY KEY identity NOT NULL,
	OrderDate DATE,
	TotalAmount DECIMAL(20,2),
	PaymentMethod varchar(10),
	CID INT FOREIGN KEY REFERENCES CUSTOMERS(CID)
);
go

CREATE TABLE Ingredients (
	IID INT PRIMARY KEY identity NOT NULL,
	IngredientName varchar(50)
);

CREATE TABLE MenuItemsTypes (
	MITID INT PRIMARY KEY identity NOT NULL,
	Type varchar(50) DEFAULT 'NON-VEGETARIAN'
);

CREATE TABLE MenuItems (
	MID INT PRIMARY KEY identity NOT NULL,
	ItemName varchar(100),
	Price DECIMAL(20,2),
	MITID INT,
	FOREIGN KEY(MITID) REFERENCES MenuItemSTypes(MITID)
);
go

CREATE TABLE MenuItemsIngredients(
	MID INT,
	IID INT,
	PRIMARY KEY(MID, IID),
	FOREIGN KEY(MID) REFERENCES MenuItems(MID),
	FOREIGN KEY (IID) REFERENCES Ingredients(IID)
	);

CREATE TABLE OrdersMenuItems (
    OID INT,
    MID INT,
    Quantity INT,
    PRIMARY KEY (OID, MID),
    FOREIGN KEY (OID) REFERENCES Orders(OID),
    FOREIGN KEY (MID) REFERENCES MenuItems(MID)
);

