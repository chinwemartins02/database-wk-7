-- Question 1: Achieving 1NF (First Normal Form)
-- The original table ProductDetail has multi-valued attributes in the Products column.
-- Goal: Transform into 1NF so that each row represents only one product per order.

-- Step 1: Create the original table (for reference/demo)
CREATE TABLE ProductDetail (
    OrderID INT,
    CustomerName VARCHAR(100),
    Products VARCHAR(255)
);

-- Step 2: Insert sample data
INSERT INTO ProductDetail (OrderID, CustomerName, Products) VALUES
(101, 'John Doe', 'Laptop, Mouse'),
(102, 'Jane Smith', 'Tablet, Keyboard, Mouse'),
(103, 'Emily Clark', 'Phone');

-- Step 3: Query to split products into separate rows (1NF)
-- Using STRING_SPLIT (SQL Server). 
-- In MySQL 8+, you can use JSON_TABLE or a recursive CTE instead.
SELECT 
    OrderID,
    CustomerName,
    LTRIM(RTRIM(value)) AS Product
FROM ProductDetail
CROSS APPLY STRING_SPLIT(Products, ',');




-- Question 2: Achieving 2NF (Second Normal Form)
-- Problem: In OrderDetails, CustomerName depends only on OrderID (partial dependency),
-- not on the full composite key (OrderID + Product).
-- Solution: Break the table into two tables: Orders and OrderItems.

-- Step 1: Original table (1NF form, for demo/reference)
CREATE TABLE OrderDetails (
    OrderID INT,
    CustomerName VARCHAR(100),
    Product VARCHAR(100),
    Quantity INT
);

-- Insert sample data
INSERT INTO OrderDetails (OrderID, CustomerName, Product, Quantity) VALUES
(101, 'John Doe', 'Laptop', 2),
(101, 'John Doe', 'Mouse', 1),
(102, 'Jane Smith', 'Tablet', 3),
(102, 'Jane Smith', 'Keyboard', 1),
(102, 'Jane Smith', 'Mouse', 2),
(103, 'Emily Clark', 'Phone', 1);

-- Step 2: Create normalized Orders table (CustomerName now depends only on OrderID)
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100)
);

-- Insert distinct OrderID + CustomerName (remove duplication)
INSERT INTO Orders (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName
FROM OrderDetails;

-- Step 3: Create normalized OrderItems table (Product depends on OrderID + Quantity)
CREATE TABLE OrderItems (
    OrderItemID INT IDENTITY(1,1) PRIMARY KEY, -- surrogate key (optional)
    OrderID INT,
    Product VARCHAR(100),
    Quantity INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- Insert product-specific data
INSERT INTO OrderItems (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity
FROM OrderDetails;

-- ✅ Final Result:
-- Orders table (OrderID, CustomerName)
-- OrderItems table (OrderItemID, OrderID, Product, Quantity)
-- All partial dependencies removed. Now CustomerName depends fully on OrderID only.
