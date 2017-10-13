GO
IF OBJECT_ID ('ProductPrices','U') IS NOT NULL 
BEGIN
	DROP TABLE ProductPrices
END

GO
IF OBJECT_ID ('Products','U') IS NOT NULL 
BEGIN
	DROP TABLE Products
END

GO
IF OBJECT_ID ('ProductTypes','U') IS NOT NULL 
BEGIN
	DROP TABLE ProductTypes
END

GO
IF OBJECT_ID ('Stores','U') IS NOT NULL 
BEGIN
	DROP TABLE Stores
END

GO
IF OBJECT_ID ('Cities','U') IS NOT NULL  
BEGIN
	DROP TABLE Cities
END

GO
CREATE TABLE ProductTypes
	(
		ProductTypeID INT IDENTITY(1,1) PRIMARY KEY
		,ProductTypeName varchar(64) NOT NULL	
	)

GO
CREATE TABLE Products
	(
		ProductID INT IDENTITY(1,1) PRIMARY KEY
		,ProductName VARCHAR(128) NOT NULL
		,ProductTypeID INT NOT NULL CONSTRAINT FK_Product_ProductTypes REFERENCES ProductTypes(ProductTypeID)
	)

GO
CREATE TABLE Cities
	(
		CityID INT IDENTITY(1,1) PRIMARY KEY
		,CityName VARCHAR(128) NOT NULL
	)

GO
CREATE TABLE Stores
	(
		StoreID INT IDENTITY(1,1) PRIMARY KEY
		,StoreName VARCHAR(128) NOT NULL
		,CityID INT NOT NULL CONSTRAINT FK_Stores_Cities REFERENCES Cities(CityID)
	)

GO
CREATE TABLE ProductPrices
	(	
		ProductPriceID INT IDENTITY(1,1) PRIMARY KEY
		,ProductID INT NOT NULL CONSTRAINT FK_ProductPrices_Products REFERENCES Products(ProductID)
		,StoreID INT NOT NULL CONSTRAINT FK_ProductPrices_Stores REFERENCES Stores(StoreID)
		,ProductPrice MONEY
		,CONSTRAINT IX_ProductPrices_UK UNIQUE CLUSTERED(ProductID,StoreID)
	)

GO