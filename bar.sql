USE master;
GO

DROP DATABASE IF EXISTS BarManagementDB;
GO

CREATE DATABASE BarManagementDB; 
GO

USE BarManagementDB; 
GO

-- 1. Создание таблиц узлов
CREATE TABLE Bartender (
    BartenderID INT IDENTITY NOT NULL,
    FirstName NVARCHAR(100) NOT NULL,
	LastName NVARCHAR(100) NOT NULL,
    Shift NVARCHAR(100) NOT NULL,
    Salary INT NOT NULL,
    CONSTRAINT PK_Bartender PRIMARY KEY (BartenderID),
    CONSTRAINT CK_SalaryNonNegative CHECK (Salary >= 0)
) AS NODE;
GO

CREATE TABLE Bar (
    BarID INT IDENTITY NOT NULL,
    Name NVARCHAR(100) NOT NULL,
	Location NVARCHAR(100) NOT NULL,
	CONSTRAINT PK_Bar PRIMARY KEY (BarID),
	CONSTRAINT UQ_BarName UNIQUE (Name)
) AS NODE;
GO

CREATE TABLE Inventory (
    InventoryID INT IDENTITY(1,1) NOT NULL,
    ItemName NVARCHAR(100) NOT NULL,
    Quantity INT NOT NULL,
    CONSTRAINT PK_Inventory PRIMARY KEY (InventoryID),
    CONSTRAINT CK_QuantityNonNegative CHECK (Quantity >= 0)
) AS NODE;
GO

-- 2. Создание таблиц ребер

CREATE TABLE BartenderBar AS EDGE;
GO

CREATE TABLE BarInventory AS EDGE;
GO

CREATE TABLE BartenderShift AS EDGE;
GO

CREATE TABLE Meet AS EDGE;
GO

-- 3. Заполнение таблиц узлов

INSERT INTO Bartender (FirstName, LastName, Shift, Salary)
VALUES
  ('John', 'Smith', 'Morning', 2000),
  ('Jane', 'Doe', 'Evening', 1800),
  ('Michael', 'Johnson', 'Night', 2200),
  ('Emily', 'Davis', 'Morning', 1900),
  ('David', 'Wilson', 'Evening', 1800),
  ('Sarah', 'Thompson', 'Night', 2100)
;
GO

INSERT INTO Bar ([Name], [Location])
VALUES
  ('Cheers', 'New York'),
  ('The Pub', 'London'),
  ('Brewery House', 'Berlin'),
  ('Hop & Barrel', 'San Francisco'),
  ('Sip & Savor', 'Tokyo'),
  ('Malty Moose', 'Sydney')
;
GO

INSERT INTO Inventory (ItemName, Quantity)
VALUES
  ('Beer', 1000),
  ('Wine', 500),
  ('Spirits', 300),
  ('Soft Drinks', 700),
  ('Snacks', 200),
  ('Beer', 2000)
;
GO


-- 4. Заполнение таблиц ребер

INSERT INTO Meet ($from_id, $to_id)
VALUES
	(
		(SELECT $node_id FROM Bartender WHERE BartenderID = 1), -- John
		(SELECT $node_id FROM Bartender WHERE BartenderID = 2) -- Jane
	),
	(
		(SELECT $node_id FROM Bartender WHERE BartenderID = 1), -- John
		(SELECT $node_id FROM Bartender WHERE BartenderID = 3) -- Michael
	),	
	(
		(SELECT $node_id FROM Bartender WHERE BartenderID = 2), -- Jane
		(SELECT $node_id FROM Bartender WHERE BartenderID = 4) -- Emily
	),	
	(
		(SELECT $node_id FROM Bartender WHERE BartenderID = 3), -- Emily
		(SELECT $node_id FROM Bartender WHERE BartenderID = 4) -- Michael
	),
	(
		(SELECT $node_id FROM Bartender WHERE BartenderID = 5), -- David
		(SELECT $node_id FROM Bartender WHERE BartenderID = 6) -- Sarah
	),
	(
		(SELECT $node_id FROM Bartender WHERE BartenderID = 6), -- Sarah
		(SELECT $node_id FROM Bartender WHERE BartenderID = 4) -- Emily
	)
;
GO

INSERT INTO BartenderBar ($from_id, $to_id)
VALUES 
	(
		(SELECT $node_id FROM Bartender WHERE BartenderID = 1), -- John Smith
		(SELECT $node_id FROM Bar WHERE BarID = 1) -- работает в баре "Cheers"
	),(
		(SELECT $node_id FROM Bartender WHERE BartenderID = 2), -- Jane Doe
		(SELECT $node_id FROM Bar WHERE BarID = 3) -- работает в баре "Brewery House"
	),(
		(SELECT $node_id FROM Bartender WHERE BartenderID = 3), -- Michael Johnson
		(SELECT $node_id FROM Bar WHERE BarID = 4) -- работает в баре "Hop & Barrel"
	),(
		(SELECT $node_id FROM Bartender WHERE BartenderID = 4), -- Emily Davis
		(SELECT $node_id FROM Bar WHERE BarID = 2) -- работает в баре "The Pub"
	),(
		(SELECT $node_id FROM Bartender WHERE BartenderID = 5), -- David Wilson
		(SELECT $node_id FROM Bar WHERE BarID = 6) -- работает в баре "Malty Moose"
	),(
		(SELECT $node_id FROM Bartender WHERE BartenderID = 6), -- Sarah Thompson
		(SELECT $node_id FROM Bar WHERE BarID = 5) -- работает в баре "Sip & Savor"
	)
;
GO

INSERT INTO BarInventory ($from_id, $to_id)
VALUES
	(
		(SELECT $node_id FROM Bar WHERE BarID = 1), -- Cheers
		(SELECT $node_id FROM Inventory WHERE InventoryID = 1) -- имеет запас пива
	),(
		(SELECT $node_id FROM Bar WHERE BarID = 2), -- The Pub
		(SELECT $node_id FROM Inventory WHERE InventoryID = 2) -- имеет запас вина
	),(
		(SELECT $node_id FROM Bar WHERE BarID = 3), -- Brewery House
		(SELECT $node_id FROM Inventory WHERE InventoryID = 3) -- имеет запас спиртных напитков
	),(
		(SELECT $node_id FROM Bar WHERE BarID = 4), -- Hop & Barrel
		(SELECT $node_id FROM Inventory WHERE InventoryID = 4) -- имеет запас безалкогольных напитков
	),(
		(SELECT $node_id FROM Bar WHERE BarID = 5), -- Sip & Savor
		(SELECT $node_id FROM Inventory WHERE InventoryID = 5) -- имеет запас закусок
	),(
		(SELECT $node_id FROM Bar WHERE BarID = 6), -- Malty Moose
		(SELECT $node_id FROM Inventory WHERE InventoryID = 6) -- имеет запас пива
	)
;
GO

INSERT INTO BartenderShift ($from_id, $to_id)
VALUES
	(
		(SELECT $node_id FROM Bartender WHERE BartenderID = 1), -- John Smith
		(SELECT $node_id FROM Bar WHERE BarID = 1) -- работает в баре "Cheers"
	),
	(
		(SELECT $node_id FROM Bartender WHERE BartenderID = 2), -- Jane Doe
		(SELECT $node_id FROM Bar WHERE BarID = 3) -- работает в баре "Brewery House"
	),
	(
		(SELECT $node_id FROM Bartender WHERE BartenderID = 3), -- Michael Johnson
		(SELECT $node_id FROM Bar WHERE BarID = 4) -- работает в баре "Hop & Barrel"
	),
	(
		(SELECT $node_id FROM Bartender WHERE BartenderID = 4), -- Emily Davis
		(SELECT $node_id FROM Bar WHERE BarID = 2) -- работает в баре "The Pub"
	),
	(
		(SELECT $node_id FROM Bartender WHERE BartenderID = 5), -- David Wilson
		(SELECT $node_id FROM Bar WHERE BarID = 6) -- работает в баре "Malty Moose"
	),
	(
		(SELECT $node_id FROM Bartender WHERE BartenderID = 6), -- Sarah Thompson
		(SELECT $node_id FROM Bar WHERE BarID = 5) -- работает в баре "Sip & Savor"
	)
;
GO

-- 5. Запросы с функцией MATCH

-- 1. Сотрудники бара "Cheers"
Select b.Lastname from Bartender as b,
BartenderBar as Bb,
Bar
Where MATCH (b-(Bb)->Bar) and Bar.[Name] = 'Cheers'

-- 2. Все бары, в которых работает бармен "John Smith"
Select Bar.[Name] from Bar,
BartenderShift as Bs,
Bartender as b
Where MATCH (b-(Bs)->Bar) and b.[FirstName] = 'John' and b.LastName = 'Smith'

-- 3. Вся информация об инвентаре бара "The Pub"
Select I.ItemName, I.Quantity from Inventory as I,
BarInventory as Bi,
Bar
Where MATCH (Bar-(Bi)->I) and Bar.[Name] = 'The Pub'

-- 4. Вся информация бармене Sarah Thompson
Select b.FirstName, b.LastName, b.Shift, b.Salary, Bar.[Name], Bar.[Location] from Bartender as b,
BartenderShift as Bs,
Bar
Where MATCH (b-(Bs)->Bar) and b.[FirstName] = 'Sarah' and b.[LastName] = 'Thompson'

-- 5. Бары, в которых есть запас пива > 1111
Select Bar.[Name] from Bar,
BarInventory as Bi,
Inventory as I
Where MATCH (Bar-(Bi)->I) and I.Quantity > 1111 and I.ItemName = 'Beer'

-- 6. Запросы с функцией SHORTEST_PATH

SELECT 
    B1.FirstName AS Bartender1Name,
    STRING_AGG(B2.FirstName, '->') WITHIN GROUP (GRAPH PATH) AS BartenderPath
FROM 
    Bartender AS B1,
	Bartender FOR PATH AS B2, 
	Meet FOR PATH AS Meet
WHERE MATCH(SHORTEST_PATH(B1(-(Meet)->B2)+))
	and B1.FirstName = 'John';

SELECT 
    B1.FirstName AS Bartender1Name,
    STRING_AGG(B2.FirstName, '->') WITHIN GROUP (GRAPH PATH) AS BartenderPath
FROM 
    Bartender AS B1,
	Bartender FOR PATH AS B2, 
	Meet FOR PATH AS Meet
WHERE MATCH(SHORTEST_PATH(B1(-(Meet)->B2){1,2}))
	and B1.FirstName = 'John';
