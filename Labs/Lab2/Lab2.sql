use Restaurant
go


insert into Customers(FirstName, LastName, Email, Phone) 
values('Ana','Tatar','ana@gmail.com','0744556677'),
('John','Doe','john.doe@gmail.com','12345678901'),
('Jane', 'Smith', 'jane.smith@yahoo.com', '9876543210'),
('Bob', 'Johnson', 'bob.johnson@gmail.com', '5551234567'),
('Lewis', 'Hamilton', 'hamilton44@gmail.com', '445592144');

insert into Customers values
('Max', 'Verstappen', 'max33@yahoo.com', '33138452311');


insert into Orders
values('2023-11-11', 50, 'card', 1),
('2023-11-11', 100.5, 'card', 2),
('2023-05-30', 21, 'card', 1),
('2023-12-01', 98.3, 'card', 3),
('2023-11-30', 10.10, 'cash', 4),
('2023-12-05', 250.31, 'cash', 3)

insert into Ingredients
values('Salt'), ('Flour'),('Butter'),('Sugar'),('Tomatoes')

insert into MenuItemsTypes
values('Vegetarian'), ('Vegan'), ('Gluten-Free'), ('Non-Vegetarian')

insert into MenuItems
values('Burger', 10.99, 4),
('Chicken Sandwich', 9.99,4),
('Veggie Wrap', 7.5, 1),
('Vegan Salad', 5.4, 2),
('Gluten-Free Pasta', 12.2, 3),
('Hummus', 3.8, 1)

--burger, salt, 12 g
insert into MenuItemsIngredients
values(12,1,1)

insert into MenuItemsIngredients
values(18,2,5)

insert into MenuItemsIngredients
values(30,3,5)

insert into MenuItemsIngredients
values(20,1,2)

insert into MenuItemsIngredients
values(10,5,1)

insert into OrdersMenuItems
values(1, 1, 2),  
  (1, 2, 1),  
  (2, 3, 3),  
  (3, 4, 1),
  (4, 5, 3)


select * from customers

update customers
set Email='lewis.hamilton44@gmail.com'
where Email LIKE '%l%' AND CID>4

select * from orders

update orders
set PaymentMethod = 'cash'
where TotalAmount BETWEEN 50 and 110 AND OID <= 2

select * from MenuItems

update menuitems
set Price = 14
where ItemName IS NOT NULL AND PRICE IN (10.99,11)

delete from customers
where FirstName LIKE 'M%' and CID = 6


--select queries

--union query

--the customers that have CID greater or equal than 3 OR the first name contains letter a 
--and the email contains letter g, ordered by name descending

select * from customers

SELECT distinct CID, FirstName from Customers
where CID >= 3
UNION
SELECT CID, FirstName from Customers
Where FirstName LIKE '%a%' AND EMAIL LIKE '%g%'
ORDER BY FirstName DESC

--intersection query
--menu items that 


--intersection query
--menu items that contain letter u and have the price greater than 4, ordered by price ascending

select * from MenuItems

SELECT ItemName, Price from MenuItems
where ItemName LIKE '%u%'
INTERSECT
SELECT ItemName, Price from MenuItems
where Price > 4
ORDER BY Price 

--except query
--ingredients that contain 'a' BUT DON'T HAVE the IID less or equal than 3 ordered by name desc

select * from Ingredients

SELECT IID, IngredientName from Ingredients
where IngredientName LIKE '%a%'
EXCEPT SELECT IID, IngredientName from Ingredients
where IID < 3
ORDER BY IngredientName DESC

--inner join
--the top 3 customers that have an order
select * from customers
select * from orders

select  top 3 * from Customers c INNER JOIN Orders o ON c.CID = O.CID

--left join
--all the customers and all their orders. If a customer doesn't have an order, it will return null
select * from Customers c LEFT JOIN Orders o ON c.CID = O.CID


--right join
--all the orders and their customer.
select * from Customers c RIGHT JOIN Orders o ON c.CID = O.CID

select* from Customers
select*from orders
select*from OrdersMenuItems

--full join
--all the orders, customers and menu items orders
select * from Customers c 
FULL OUTER JOIN Orders o ON c.CID = O.CID
FULL OUTER JOIN OrdersMenuItems m on o.OID = m.OID

--query using IN
--all the customers that have in the first name letter 'o' 
--and have an order on 2023-11-11
select* from Customers
select*from orders

update orders
set OrderDate = '2023-11-11'
where OrderDate = '2023-11-30'

SELECT FirstName, LastName
FROM Customers
WHERE FirstName LIKE '%o%' and CID IN (SELECT CID FROM Orders WHERE OrderDate = '2023-11-11');


--query using EXISTS
--customers names with first name containing 'o' that have orders

select* from Customers
select*from orders

SELECT FirstName, LastName
FROM Customers C
WHERE FirstName LIKE '%o%' and EXISTS (SELECT * FROM Orders O WHERE O.CID = C.CID);

--query with a subquery using FROM
--customers names with first name containing 'o' that have orders

select* from Customers
select*from orders

select A.FirstName, A.OrderDate
FROM(SELECT  c.FirstName, o.OrderDate FROM Customers c 
INNER JOIN Orders o on c.CID = o.CID where FirstName LIKE '%o%') A

--group by with having clause
--total orders for each customer who has at leas 1 one order
SELECT C.FirstName, C.LastName, COUNT(O.OID) AS OrderCount
FROM Customers C
LEFT JOIN Orders O ON C.CID = O.CID
GROUP BY C.FirstName, C.LastName
HAVING COUNT(O.OID) >= 1;

--group by with having clause and subquery
-- Find customers with an average order amount greater than the overall average
SELECT C.FirstName, C.LastName, AVG(O.TotalAmount) AS AvgOrderAmount
FROM Customers C
LEFT JOIN Orders O ON C.CID = O.CID
GROUP BY C.FirstName, C.LastName
HAVING AVG(O.TotalAmount) > (SELECT AVG(TotalAmount) FROM Orders);


--query wih group by
-- Count, average, min, max, and total order amounts per customer 
-- who has at least one order(right join)
SELECT C.FirstName, C.LastName, 
       COUNT(O.OID) AS OrderCount,
       AVG(O.TotalAmount) AS AvgOrderAmount,
       MIN(O.TotalAmount) AS MinOrderAmount,
       MAX(O.TotalAmount) AS MaxOrderAmount,
       SUM(O.TotalAmount) AS TotalOrderAmount
FROM Customers C
RIGHT JOIN Orders O ON C.CID = O.CID
GROUP BY C.FirstName, C.LastName;
