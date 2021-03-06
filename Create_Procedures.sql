---------------------------------------------------
--ProductTypes
---------------------------------------------------
CREATE PROCEDURE [dbo].[dict_ProductTypes_Insert]
	(
		@ProductTypeName varchar(64)
		,@UserMsg VARCHAR(256) NULL output
	)
AS
BEGIN

	DECLARE @TranCheck		BIT
	DECLARE @TranName		SYSNAME

	SET @UserMsg	=	NULLIF(LTRIM(@UserMsg), '')
	SET @TranCheck	=	CASE WHEN @@TRANCOUNT > 0 or @@OPTIONS & 2 > 0 THEN 1 ELSE 0 END
	SET @TranName 	=	OBJECT_NAME(@@PROCID) + '-' + convert(varchar(10), @@NESTLEVEL)

	IF @TranCheck = 0 BEGIN TRAN ELSE SAVE TRAN @TranName
---------------------------------------
--
---------------------------------------	
	IF NULLIF(LTRIM(@ProductTypeName),'') IS NULL
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! ProductTypeName could''t be empty.'
		GOTO ErrorReturn	
	END

	IF EXISTS (SELECT 1 FROM ProductTypes WHERE ProductTypeName = @ProductTypeName)
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! ' + isnull(@ProductTypeName,'') + 'Already exist in the table.'
		GOTO ErrorReturn
	END
---------------------------------------
--
---------------------------------------

	BEGIN TRY
		INSERT INTO ProductTypes(ProductTypeName)
		SELECT @ProductTypeName

		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'ProductType add.'
	END TRY
	BEGIN CATCH
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + ERROR_MESSAGE()
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! ProductType dont add.'
		GOTO ErrorReturn
	END CATCH
---------------------------------------
--
---------------------------------------
NormalReturn:
	IF (@TranCheck = 0) COMMIT TRAN
	RETURN	0 
ErrorReturn:
	IF (@@TRANCOUNT > 0)
	BEGIN
		if @TranCheck = 0 ROLLBACK TRAN 
		ELSE ROLLBACK TRAN @TranName
	END	
	RETURN	100
END

GO

CREATE PROCEDURE [dbo].[dict_ProductTypes_Update]
	(
		@ProductTypeID int
		,@ProductTypeName varchar(64)
		,@UserMsg VARCHAR(256) NULL output
	)
AS
BEGIN

	DECLARE @TranCheck		BIT
	DECLARE @TranName		SYSNAME

	SET @UserMsg	=	NULLIF(LTRIM(@UserMsg), '')
	SET @TranCheck	=	CASE WHEN @@TRANCOUNT > 0 or @@OPTIONS & 2 > 0 THEN 1 ELSE 0 END
	SET @TranName 	=	OBJECT_NAME(@@PROCID) + '-' + convert(varchar(10), @@NESTLEVEL)

	IF @TranCheck = 0 BEGIN TRAN ELSE SAVE TRAN @TranName
---------------------------------------
--
---------------------------------------	
	IF NOT EXISTS (SELECT 1 FROM ProductTypes WHERE ProductTypes.ProductTypeID = @ProductTypeID)
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! ProductTypeID [' + convert(varchar(10),@ProductTypeID) + 'not find in the list.'
		GOTO ErrorReturn
	END

	IF NULLIF(LTRIM(@ProductTypeName),'') IS NULL
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! ProductTypeName could''t be empty.'
		GOTO ErrorReturn	
	END

	IF EXISTS (SELECT 1 FROM ProductTypes WHERE ProductTypes.ProductTypeID <> @ProductTypeID AND ProductTypeName = @ProductTypeName)
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! ' + @ProductTypeName + 'Already exist in the table.'
		GOTO ErrorReturn
	END
---------------------------------------
--
---------------------------------------
	BEGIN TRY
		UPDATE ProductTypes
		SET ProductTypeName = ProductTypeName
		FROM ProductTypes
		WHERE ProductTypeID = @ProductTypeID

		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'ProductType update.'
	END TRY
	BEGIN CATCH
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + ERROR_MESSAGE()
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! ProductType dont update.'
		GOTO ErrorReturn
	END CATCH
---------------------------------------
--
---------------------------------------
NormalReturn:
	IF (@TranCheck = 0) COMMIT TRAN
	RETURN	0 
ErrorReturn:
	IF (@@TRANCOUNT > 0)
	BEGIN
		if @TranCheck = 0 ROLLBACK TRAN 
		ELSE ROLLBACK TRAN @TranName
	END	
	RETURN	100
END

GO

CREATE PROCEDURE [dbo].[dict_ProductTypes_Get]
	(
		@ProductTypeID int null
		,@SearchStr varchar(64) = NULL
	)
AS
BEGIN
	SET @SearchStr = NULLIF(LTRIM(@SearchStr),'')

	SELECT
		ProductTypeID
		,ProductTypeName
	FROM ProductTypes
	WHERE (@ProductTypeID IS NULL OR ProductTypeID = @ProductTypeID)
		AND (@SearchStr IS NULL OR ProductTypeName LIKE '%' + @SearchStr + '%')
END
GO

CREATE PROCEDURE [dbo].[dict_ProductTypes_Delete]
	(
		@ProductTypeID int
		,@UserMsg VARCHAR(256) NULL output
	)
AS
BEGIN

	DECLARE @TranCheck		BIT
	DECLARE @TranName		SYSNAME

	SET @UserMsg	=	NULLIF(LTRIM(@UserMsg), '')
	SET @TranCheck	=	CASE WHEN @@TRANCOUNT > 0 or @@OPTIONS & 2 > 0 THEN 1 ELSE 0 END
	SET @TranName 	=	OBJECT_NAME(@@PROCID) + '-' + convert(varchar(10), @@NESTLEVEL)

	IF @TranCheck = 0 BEGIN TRAN ELSE SAVE TRAN @TranName
---------------------------------------
--
---------------------------------------	
	DECLARE @ProductTypeName VARCHAR(64)
	
	IF NOT EXISTS (SELECT 1 FROM ProductTypes WHERE ProductTypes.ProductTypeID = @ProductTypeID)
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! ProductTypeID [' + CONVERT(VARCHAR(10),@ProductTypeID) + '] Not find in the table.'
		GOTO ErrorReturn
	END

	SELECT @ProductTypeName = ProductTypeName
	FROM ProductTypes
	WHERE ProductTypes.ProductTypeID = @ProductTypeID

	IF EXISTS (SELECT 1 FROM Products WHERE Products.ProductTypeID = @ProductTypeID)
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! Could not delete ProductType [' + @ProductTypeName + '] it already use in products.'
		GOTO ErrorReturn
	END
---------------------------------------
--
---------------------------------------
	BEGIN TRY
		DELETE FROM ProductTypes WHERE ProductTypeID = @ProductTypeID

		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'ProductType [' + @ProductTypeName + '] deleted.'
	END TRY
	BEGIN CATCH
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + ERROR_MESSAGE()
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! ProductType [' + @ProductTypeName + '] dont deleted.'
		GOTO ErrorReturn
	END CATCH
---------------------------------------
--
---------------------------------------
NormalReturn:
	IF (@TranCheck = 0) COMMIT TRAN
	RETURN	0 
ErrorReturn:
	IF (@@TRANCOUNT > 0)
	BEGIN
		if @TranCheck = 0 ROLLBACK TRAN 
		ELSE ROLLBACK TRAN @TranName
	END	
	RETURN	100
END
GO

---------------------------------------------------
--Products
---------------------------------------------------
CREATE PROCEDURE [dbo].[doc_Products_Xml_Insert]
	(
		@XML varchar(MAX)
		,@UserMsg VARCHAR(256) output
	)
AS
BEGIN
	DECLARE @TranCheck		BIT
	DECLARE @TranName		SYSNAME

	SET @UserMsg	=	NULLIF(LTRIM(@UserMsg), '')
	SET @TranCheck	=	CASE WHEN @@TRANCOUNT > 0 or @@OPTIONS & 2 > 0 THEN 1 ELSE 0 END
	SET @TranName 	=	OBJECT_NAME(@@PROCID) + '-' + convert(varchar(10), @@NESTLEVEL)

	IF @TranCheck = 0 BEGIN TRAN ELSE SAVE TRAN @TranName
---------------------------------------
--
---------------------------------------	
	DECLARE @idoc int
	DECLARE @x TABLE 
		(
			ProductName varchar(128)
			,ProductTypeID int
			,isProductTypeIDExist bit
			,isProductAlreadyExist bit
		)
---------------------------------------
--
---------------------------------------	
	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML

	INSERT INTO @x (ProductName,ProductTypeID)
	
	SELECT DISTINCT ProductName,ProductTypeID
	FROM OPENXML (@idoc, '/Root/A',1)
		  WITH
		  (		
			ProductName varchar(128) '@Product'
			,ProductTypeID int '@ProductTypeID'
		  ) AS [xmlSrc]

	EXEC sp_xml_removedocument @idoc

---------------------------------------
--check for ProductName nor null
---------------------------------------
	UPDATE @x
	SET ProductName = NULLIF(LTRIM(ProductName),'')

	IF EXISTS 
		(
			SELECT 1 FROM @X WHERE ProductName IS NULL
		)
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! Some product has empty name'
		GOTO ErrorReturn
	END
-----------
---------------------------------------
--check for unknown ProductTypeID
---------------------------------------
	UPDATE x
	SET isProductTypeIDExist = CASE 
									WHEN ProductTypes.ProductTypeID IS NOT NULL THEN 1 
									ELSE 0 
								END
	FROM @x AS x
	LEFT JOIN ProductTypes
		ON ProductTypes.ProductTypeID = x.ProductTypeID

	IF EXISTS 
		(
			SELECT 1 FROM @X WHERE isProductTypeIDExist = 0
		)
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! Some product has unknown ProductTypeID'
		GOTO ErrorReturn
	END
---------------------------------------
--check for ProductName what already exist in Products
---------------------------------------
	UPDATE x
	SET isProductAlreadyExist = CASE 
									WHEN Products.ProductName IS NOT NULL THEN 1 
									ELSE 0 
								END
	FROM @x AS x
	LEFT JOIN Products
		ON Products.ProductName = x.ProductName

	IF EXISTS 
		(
			SELECT 1 FROM @X WHERE isProductAlreadyExist = 1
		)
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! Some ProductName exist int Product'
		GOTO ErrorReturn
	END
---------------------------------------
--
---------------------------------------

	BEGIN TRY
		INSERT INTO Products(ProductName,ProductTypeID)
		select ProductName,ProductTypeID
		from @x

		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Product Add.'
	END TRY
	BEGIN CATCH
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + ERROR_MESSAGE()
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! Product dont add.'
		GOTO ErrorReturn
	END CATCH
---------------------------------------
--
---------------------------------------
NormalReturn:
	IF (@TranCheck = 0) COMMIT TRAN
	RETURN	0 
ErrorReturn:
	IF (@@TRANCOUNT > 0)
	BEGIN
		if @TranCheck = 0 ROLLBACK TRAN 
		ELSE ROLLBACK TRAN @TranName
	END	
	RETURN	100
END

GO

CREATE PROCEDURE [dbo].[doc_Products_Update]
	(
		@ProductID INT
		,@ProductName VARCHAR(128)
		,@ProductTypeID int
		,@UserMsg VARCHAR(256) output
	)
AS
BEGIN
	DECLARE @TranCheck		BIT
	DECLARE @TranName		SYSNAME

	SET @UserMsg	=	NULLIF(LTRIM(@UserMsg), '')
	SET @TranCheck	=	CASE WHEN @@TRANCOUNT > 0 or @@OPTIONS & 2 > 0 THEN 1 ELSE 0 END
	SET @TranName 	=	OBJECT_NAME(@@PROCID) + '-' + convert(varchar(10), @@NESTLEVEL)

	IF @TranCheck = 0 BEGIN TRAN ELSE SAVE TRAN @TranName
---------------------------------------
--check for ProductName nor null
---------------------------------------
	IF NOT EXISTS 
		(
			SELECT 1 FROM Products WHERE ProductID = @ProductID
		)
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! ProductID not find.'
		GOTO ErrorReturn
	END

	IF NULLIF(LTRIM(@ProductName),'') IS NULL
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! ProductName is empty.'
		GOTO ErrorReturn
	END
---------------------------------------
	IF EXISTS 
		(
			SELECT 1 FROM Products WHERE ProductID <> @ProductID AND ProductName = @ProductName 
		)
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! Some product has the same name [' + @ProductName + '].'
		GOTO ErrorReturn
	END
---------------------------------------
	IF NOT EXISTS 
		(
			SELECT 1 FROM ProductTypes WHERE ProductTypeID = @ProductTypeID
		)
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! Unkrown ProductTypeID.'
		GOTO ErrorReturn
	END
---------------------------------------
--
---------------------------------------
	BEGIN TRY
		UPDATE Products
		SET ProductName = @ProductName
			,ProductTypeID = @ProductTypeID
		FROM Products
		WHERE Products.ProductID = @ProductID

		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Product updated.'
	END TRY
	BEGIN CATCH
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + ERROR_MESSAGE()
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! Product didnt updated.'
		GOTO ErrorReturn
	END CATCH
---------------------------------------
--
---------------------------------------
NormalReturn:
	IF (@TranCheck = 0) COMMIT TRAN
	RETURN	0 
ErrorReturn:
	IF (@@TRANCOUNT > 0)
	BEGIN
		if @TranCheck = 0 ROLLBACK TRAN 
		ELSE ROLLBACK TRAN @TranName
	END	
	RETURN	100
END

GO

CREATE PROCEDURE [dbo].[doc_Products_Get]
	(
		@ProductID INT NULL
		,@ProductName VARCHAR(128) NULL
		,@ProductTypeID INT NULL
	)
AS
BEGIN
	SELECT Products.ProductID
		,Products.ProductName
		,Products.ProductTypeID
		,ProductTypes.ProductTypeName
	FROM Products
	JOIN ProductTypes 
		ON ProductTypes.ProductTypeID = Products.ProductTypeID
	WHERE (@ProductID IS NULL OR Products.ProductID = @ProductID)
		AND (@ProductTypeID IS NULL OR Products.ProductTypeID  = @ProductTypeID)
		AND (@ProductName IS NULL OR Products.ProductName = @ProductName )
END
GO

CREATE PROCEDURE [dbo].[doc_Products_Delete]
	(
		@ProductID INT
		,@UserMsg VARCHAR(256) NULL OUTPUT
	)
AS
BEGIN
	DECLARE @TranCheck		BIT
	DECLARE @TranName		SYSNAME

	SET @UserMsg	=	NULLIF(LTRIM(@UserMsg), '')
	SET @TranCheck	=	CASE WHEN @@TRANCOUNT > 0 or @@OPTIONS & 2 > 0 THEN 1 ELSE 0 END
	SET @TranName 	=	OBJECT_NAME(@@PROCID) + '-' + convert(varchar(10), @@NESTLEVEL)

	IF @TranCheck = 0 BEGIN TRAN ELSE SAVE TRAN @TranName
---------------------------------------
--check for ProductName nor null
---------------------------------------
	IF EXISTS 
		(
			SELECT 1 FROM ProductPrices WHERE ProductID = @ProductID
		)
	BEGIN
		BEGIN TRY
			DELETE FROM ProductPrices WHERE ProductID = @ProductID

			SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'ProductPrice Deleted'
		END TRY
		BEGIN CATCH
			SET @UserMsg = ISNULL(@UserMsg + ' | ','') + ERROR_MESSAGE()
			SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! ProductPrice dont delete.'
			GOTO ErrorReturn
		END CATCH
	END

---------------------------------------
--
---------------------------------------
	BEGIN TRY
		DELETE FROM Products WHERE ProductID = @ProductID

		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Product Deleted'
	END TRY
	BEGIN CATCH
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + ERROR_MESSAGE()
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! Product dont delete.'
		GOTO ErrorReturn
	END CATCH
---------------------------------------
--
---------------------------------------
NormalReturn:
	IF (@TranCheck = 0) COMMIT TRAN
	RETURN	0 
ErrorReturn:
	IF (@@TRANCOUNT > 0)
	BEGIN
		if @TranCheck = 0 ROLLBACK TRAN 
		ELSE ROLLBACK TRAN @TranName
	END	
	RETURN	100
END
GO

---------------------------------------------------
--Cities
---------------------------------------------------
CREATE PROCEDURE [dbo].[dict_Cities_Insert]
	(
		@CityName varchar(128)
		,@UserMsg VARCHAR(256) NULL output
	)
AS
BEGIN

	DECLARE @TranCheck		BIT
	DECLARE @TranName		SYSNAME

	SET @UserMsg	=	NULLIF(LTRIM(@UserMsg), '')
	SET @TranCheck	=	CASE WHEN @@TRANCOUNT > 0 or @@OPTIONS & 2 > 0 THEN 1 ELSE 0 END
	SET @TranName 	=	OBJECT_NAME(@@PROCID) + '-' + convert(varchar(10), @@NESTLEVEL)

	IF @TranCheck = 0 BEGIN TRAN ELSE SAVE TRAN @TranName
---------------------------------------
--
---------------------------------------	
	IF NULLIF(LTRIM(@CityName),'') IS NULL
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! CityName could''t be empty.'
		GOTO ErrorReturn	
	END

	IF EXISTS (SELECT 1 FROM Cities WHERE CityName = @CityName)
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! ' + @CityName + 'Already exist in the table.'
		GOTO ErrorReturn
	END
---------------------------------------
--
---------------------------------------

	BEGIN TRY
		INSERT INTO Cities(CityName)
		SELECT @CityName

		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'CityName add.'
	END TRY
	BEGIN CATCH
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + ERROR_MESSAGE()
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! CityName dont add.'
		GOTO ErrorReturn
	END CATCH
---------------------------------------
--
---------------------------------------
NormalReturn:
	IF (@TranCheck = 0) COMMIT TRAN
	RETURN	0 
ErrorReturn:
	IF (@@TRANCOUNT > 0)
	BEGIN
		if @TranCheck = 0 ROLLBACK TRAN 
		ELSE ROLLBACK TRAN @TranName
	END	
	RETURN	100
END
GO

CREATE PROCEDURE [dbo].[dict_Cities_Update]
	(
		@CityID int
		,@CityName varchar(128)
		,@UserMsg VARCHAR(256) NULL OUTPUT
	)
AS
BEGIN

	DECLARE @TranCheck		BIT
	DECLARE @TranName		SYSNAME

	SET @UserMsg	=	NULLIF(LTRIM(@UserMsg), '')
	SET @TranCheck	=	CASE WHEN @@TRANCOUNT > 0 or @@OPTIONS & 2 > 0 THEN 1 ELSE 0 END
	SET @TranName 	=	OBJECT_NAME(@@PROCID) + '-' + convert(varchar(10), @@NESTLEVEL)

	IF @TranCheck = 0 BEGIN TRAN ELSE SAVE TRAN @TranName
---------------------------------------
--
---------------------------------------	
	IF NOT EXISTS (SELECT 1 FROM Cities WHERE Cities.CityID = @CityID)
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! CityID [' + convert(varchar(10),@CityID) + 'not find in the list.'
		GOTO ErrorReturn
	END

	IF NULLIF(LTRIM(@CityName),'') IS NULL
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! CityName could''t be empty.'
		GOTO ErrorReturn	
	END

	IF EXISTS (SELECT 1 FROM Cities WHERE Cities.CityID <> @CityID AND CityName = @CityName)
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! ' + @CityName + 'Already exist in the table.'
		GOTO ErrorReturn
	END
---------------------------------------
--
---------------------------------------
	BEGIN TRY
		UPDATE Cities
		SET CityName = @CityName
		FROM Cities
		WHERE CityID = @CityID

		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'CityName update.'
	END TRY
	BEGIN CATCH
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + ERROR_MESSAGE()
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! CityName dont update.'
		GOTO ErrorReturn
	END CATCH
---------------------------------------
--
---------------------------------------
NormalReturn:
	IF (@TranCheck = 0) COMMIT TRAN
	RETURN	0 
ErrorReturn:
	IF (@@TRANCOUNT > 0)
	BEGIN
		if @TranCheck = 0 ROLLBACK TRAN 
		ELSE ROLLBACK TRAN @TranName
	END	
	RETURN	100
END
GO

 CREATE PROCEDURE [dbo].[dict_Cities_Get]
	(
		@CityID int null
		,@SearchStr varchar(128) = NULL
	)
AS
BEGIN
	SET @SearchStr = NULLIF(LTRIM(@SearchStr),'')

	SELECT
		CityID
		,CityName
	FROM Cities
	WHERE (@CityID IS NULL OR CityID = @CityID)
		AND (@SearchStr IS NULL OR CityName LIKE '%' + @SearchStr + '%')
END
GO

CREATE PROCEDURE [dbo].[dict_Cities_Delete]
	(
		@CityID int
		,@UserMsg VARCHAR(256) NULL output
	)
AS
BEGIN

	DECLARE @TranCheck		BIT
	DECLARE @TranName		SYSNAME

	SET @UserMsg	=	NULLIF(LTRIM(@UserMsg), '')
	SET @TranCheck	=	CASE WHEN @@TRANCOUNT > 0 or @@OPTIONS & 2 > 0 THEN 1 ELSE 0 END
	SET @TranName 	=	OBJECT_NAME(@@PROCID) + '-' + convert(varchar(10), @@NESTLEVEL)

	IF @TranCheck = 0 BEGIN TRAN ELSE SAVE TRAN @TranName
---------------------------------------
--
---------------------------------------	
	DECLARE @CityName VARCHAR(128)
	
	IF NOT EXISTS (SELECT 1 FROM Cities WHERE Cities.CityID = @CityID)
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! CityID [' + CONVERT(VARCHAR(10),@CityID) + '] Not find in the table.'
		GOTO ErrorReturn
	END

	SELECT @CityName = CityName
	FROM Cities
	WHERE Cities.CityID = @CityID

	IF EXISTS (SELECT 1 FROM Stores WHERE Stores.CityID = @CityID)
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! Could not delete City [' + @CityName + '] it already use in Stores.'
		GOTO ErrorReturn
	END
---------------------------------------
--
---------------------------------------
	BEGIN TRY
		DELETE FROM Cities WHERE Cities.CityID = @CityID

		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'City [' + @CityName + '] deleted.'
	END TRY
	BEGIN CATCH
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + ERROR_MESSAGE()
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! City [' + @CityName + '] dont deleted.'
		GOTO ErrorReturn
	END CATCH
---------------------------------------
--
---------------------------------------
NormalReturn:
	IF (@TranCheck = 0) COMMIT TRAN
	RETURN	0 
ErrorReturn:
	IF (@@TRANCOUNT > 0)
	BEGIN
		if @TranCheck = 0 ROLLBACK TRAN 
		ELSE ROLLBACK TRAN @TranName
	END	
	RETURN	100
END
GO

---------------------------------------------------
--Stores
---------------------------------------------------

CREATE PROCEDURE [dbo].[dict_Stores_Insert]
	(
		@StoreName varchar(128)
		,@CityID int
		,@UserMsg VARCHAR(256) NULL output
	)
AS
BEGIN

	DECLARE @TranCheck		BIT
	DECLARE @TranName		SYSNAME

	SET @UserMsg	=	NULLIF(LTRIM(@UserMsg), '')
	SET @TranCheck	=	CASE WHEN @@TRANCOUNT > 0 or @@OPTIONS & 2 > 0 THEN 1 ELSE 0 END
	SET @TranName 	=	OBJECT_NAME(@@PROCID) + '-' + convert(varchar(10), @@NESTLEVEL)

	IF @TranCheck = 0 BEGIN TRAN ELSE SAVE TRAN @TranName
---------------------------------------
--
---------------------------------------	
	IF NULLIF(LTRIM(@StoreName),'') IS NULL
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! StoreName could''t be empty.'
		GOTO ErrorReturn	
	END

	IF EXISTS (SELECT 1 FROM Stores WHERE StoreName = @StoreName)
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! ' + @StoreName + 'Already exist in the table.'
		GOTO ErrorReturn
	END

	IF NOT EXISTS (SELECT 1 FROM Cities where CityID = @CityID)
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! ' + CONVERT(VARCHAR(10),@CityID) + ' not find in the table.'
		GOTO ErrorReturn
	END
---------------------------------------
--
---------------------------------------

	BEGIN TRY
		INSERT INTO Stores(StoreName,CityID)
		SELECT @StoreName,@CityID

		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Store add.'
	END TRY
	BEGIN CATCH
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + ERROR_MESSAGE()
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! Store dont add.'
		GOTO ErrorReturn
	END CATCH
---------------------------------------
--
---------------------------------------
NormalReturn:
	IF (@TranCheck = 0) COMMIT TRAN
	RETURN	0 
ErrorReturn:
	IF (@@TRANCOUNT > 0)
	BEGIN
		if @TranCheck = 0 ROLLBACK TRAN 
		ELSE ROLLBACK TRAN @TranName
	END	
	RETURN	100
END
GO

CREATE PROCEDURE [dbo].[dict_Stores_Update]
	(
		@StoreID int
		,@StoreName VARCHAR(128)
		,@CityID int
		,@UserMsg VARCHAR(256) NULL OUTPUT
	)
AS
BEGIN

	DECLARE @TranCheck		BIT
	DECLARE @TranName		SYSNAME

	SET @UserMsg	=	NULLIF(LTRIM(@UserMsg), '')
	SET @TranCheck	=	CASE WHEN @@TRANCOUNT > 0 or @@OPTIONS & 2 > 0 THEN 1 ELSE 0 END
	SET @TranName 	=	OBJECT_NAME(@@PROCID) + '-' + convert(varchar(10), @@NESTLEVEL)

	IF @TranCheck = 0 BEGIN TRAN ELSE SAVE TRAN @TranName
---------------------------------------
--
---------------------------------------	
	IF NOT EXISTS (SELECT 1 FROM Stores WHERE Stores.StoreID = @StoreID)
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! StoreID [' + convert(varchar(10),@StoreID) + 'not find in the list.'
		GOTO ErrorReturn
	END

	IF NOT EXISTS (SELECT 1 FROM Cities WHERE Cities.CityID = @CityID)
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! CityID [' + convert(varchar(10),@CityID) + 'not find in the list.'
		GOTO ErrorReturn
	END

	IF NULLIF(LTRIM(@StoreName),'') IS NULL
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! CityName could''t be empty.'
		GOTO ErrorReturn	
	END

	IF EXISTS (SELECT 1 FROM Stores WHERE Stores.StoreID <> @StoreID AND StoreName = @StoreName)
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! ' + @StoreName + 'Already exist in the table.'
		GOTO ErrorReturn
	END
---------------------------------------
--
---------------------------------------
	BEGIN TRY
		UPDATE Stores
		SET StoreName = @StoreName
		FROM Stores
		WHERE StoreID = @StoreID

		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'StoreName update.'
	END TRY
	BEGIN CATCH
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + ERROR_MESSAGE()
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! StoreName dont update.'
		GOTO ErrorReturn
	END CATCH
---------------------------------------
--
---------------------------------------
NormalReturn:
	IF (@TranCheck = 0) COMMIT TRAN
	RETURN	0 
ErrorReturn:
	IF (@@TRANCOUNT > 0)
	BEGIN
		if @TranCheck = 0 ROLLBACK TRAN 
		ELSE ROLLBACK TRAN @TranName
	END	
	RETURN	100
END
GO

CREATE PROCEDURE [dbo].[dict_Stores_Get]
	(
		@StoreID int NULL
		,@CityID int NULL
		,@SearchStr varchar(128) NULL
	)
AS
BEGIN
	SET @SearchStr = NULLIF(LTRIM(@SearchStr),'')

	SELECT
		Stores.StoreID
		,Stores.StoreName
		,Stores.CityID
		,Cities.CityName
	FROM Stores
	JOIN Cities
		ON Cities.CityID = Stores.CityID
	WHERE (@StoreID IS NULL OR Stores.StoreID = @StoreID)
		AND (@CityID IS NULL OR Cities.CityID = @CityID)
		AND (@SearchStr IS NULL OR Stores.StoreName LIKE '%' + @SearchStr + '%')
END
GO

CREATE PROCEDURE [dbo].[dict_Stores_Delete]
	(
		@StoreID int
		,@UserMsg VARCHAR(256) NULL OUTPUT
	)
AS
BEGIN

	DECLARE @TranCheck		BIT
	DECLARE @TranName		SYSNAME

	SET @UserMsg	=	NULLIF(LTRIM(@UserMsg), '')
	SET @TranCheck	=	CASE WHEN @@TRANCOUNT > 0 or @@OPTIONS & 2 > 0 THEN 1 ELSE 0 END
	SET @TranName 	=	OBJECT_NAME(@@PROCID) + '-' + convert(varchar(10), @@NESTLEVEL)

	IF @TranCheck = 0 BEGIN TRAN ELSE SAVE TRAN @TranName
---------------------------------------
--
---------------------------------------	
	DECLARE @StoreName varchar(128)

	IF NOT EXISTS (SELECT 1 FROM Stores WHERE Stores.StoreID = @StoreID)
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! StoreID [' + convert(varchar(10),@StoreID) + 'not find in the list.'
		GOTO ErrorReturn
	END

	SELECT @StoreName = StoreName
	FROM Stores 
	WHERE Stores.StoreID = @StoreID

	IF EXISTS (SELECT 1 FROM ProductPrices WHERE ProductPrices.StoreID = @StoreID)
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! StoreID [' + convert(varchar(10),@StoreID) + '] use in table ProductPrices.'
		GOTO ErrorReturn
	END
---------------------------------------
--
---------------------------------------
	BEGIN TRY
		DELETE Stores WHERE StoreID = @StoreID

		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Store [' + @StoreName + '] deleted.'
	END TRY
	BEGIN CATCH
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + ERROR_MESSAGE()
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! StoreName [' + @StoreName + '] dint deleted.'
		GOTO ErrorReturn
	END CATCH
---------------------------------------
--
---------------------------------------
NormalReturn:
	IF (@TranCheck = 0) COMMIT TRAN
	RETURN	0 
ErrorReturn:
	IF (@@TRANCOUNT > 0)
	BEGIN
		if @TranCheck = 0 ROLLBACK TRAN 
		ELSE ROLLBACK TRAN @TranName
	END	
	RETURN	100
END
GO

---------------------------------------------------
--ProductPrices
---------------------------------------------------

CREATE PROCEDURE [dbo].[doc_ProductPrices_Insert]
	(
		@ProductID INT
		,@StoreID INT
		,@ProductPrice MONEY
		,@UserMsg VARCHAR(256) NULL output
	)
AS
BEGIN

	DECLARE @TranCheck		BIT
	DECLARE @TranName		SYSNAME

	SET @UserMsg	=	NULLIF(LTRIM(@UserMsg), '')
	SET @TranCheck	=	CASE WHEN @@TRANCOUNT > 0 or @@OPTIONS & 2 > 0 THEN 1 ELSE 0 END
	SET @TranName 	=	OBJECT_NAME(@@PROCID) + '-' + convert(varchar(10), @@NESTLEVEL)

	IF @TranCheck = 0 BEGIN TRAN ELSE SAVE TRAN @TranName
---------------------------------------
--
---------------------------------------	
	DECLARE @ProductName varchar(128)
	DECLARE @StoreName varchar(128)

	IF NOT EXISTS (SELECT 1 FROM Stores WHERE StoreID = @StoreID)
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! Store [' + CONVERT(VARCHAR(10),@StoreID) + '] not find in the table.'
		GOTO ErrorReturn
	END

	IF NOT EXISTS (SELECT 1 FROM Products where ProductID = @ProductID)
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! Products [' + CONVERT(VARCHAR(10),@ProductID) + '] not find in the table.'
		GOTO ErrorReturn
	END

	IF ISNULL(@ProductPrice,0) <= 0
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! @ProductPrice could not be empty or negative.'
		GOTO ErrorReturn
	END

	SELECT @ProductName = ProductName
	FROM Products
	WHERE ProductID = @ProductID
	
	SELECT @StoreName = StoreName
	FROM Stores
	WHERE Stores.StoreID = @StoreID  

	IF EXISTS (SELECT 1 FROM ProductPrices WHERE ProductID = @ProductID AND StoreID = @StoreID)
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! Product [' + @ProductName + '] on store [' + @StoreName + '] already has price.'
		GOTO ErrorReturn
	END
---------------------------------------
--
---------------------------------------

	BEGIN TRY
		INSERT INTO ProductPrices(ProductID,StoreID,ProductPrice)
		SELECT @ProductID,@StoreID,@ProductPrice

		SET @UserMsg = ISNULL(@UserMsg + ' | ','') +  'Product [' + @ProductName + '] on store [' + @StoreName + ']  add price [' + convert(varchar(30),@ProductPrice) + '].'
	END TRY
	BEGIN CATCH
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + ERROR_MESSAGE()
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! Store dont add.'
		GOTO ErrorReturn
	END CATCH
---------------------------------------
--
---------------------------------------
NormalReturn:
	IF (@TranCheck = 0) COMMIT TRAN
	RETURN	0 
ErrorReturn:
	IF (@@TRANCOUNT > 0)
	BEGIN
		if @TranCheck = 0 ROLLBACK TRAN 
		ELSE ROLLBACK TRAN @TranName
	END	
	RETURN	100
END
GO

CREATE PROCEDURE [dbo].[doc_ProductPrices_XML_Save]
	(
		@XML vARCHAR(MAX)
		,@isPriceReplace bit
		,@UserMsg VARCHAR(256) NULL output
	)
AS
BEGIN

	DECLARE @TranCheck		BIT
	DECLARE @TranName		SYSNAME

	SET @UserMsg	=	NULLIF(LTRIM(@UserMsg), '')
	SET @TranCheck	=	CASE WHEN @@TRANCOUNT > 0 or @@OPTIONS & 2 > 0 THEN 1 ELSE 0 END
	SET @TranName 	=	OBJECT_NAME(@@PROCID) + '-' + convert(varchar(10), @@NESTLEVEL)

	IF @TranCheck = 0 BEGIN TRAN ELSE SAVE TRAN @TranName
---------------------------------------
--
---------------------------------------	
	DECLARE @idoc int
	DECLARE @x TABLE 
		(
			ProductID int not null
			,StoreID int
			,Price money
		)
---------------------------------------
--products
---------------------------------------	
	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML

	INSERT INTO @x (ProductID,StoreID,Price)
	SELECT ProductID,StoreID,Price
	FROM OPENXML (@idoc, '/Root/A',1)
		  WITH
		  (		
			ProductID int '@ProductID'
			,StoreID int '@StoreID'
			,Price money '@Price'
		  ) AS [xmlSrc]

	EXEC sp_xml_removedocument @idoc
---------------------------------------
--
---------------------------------------	
	IF EXISTS 
		(
			SELECT 1 
			FROM @x AS x
			left join Stores
				on Stores.StoreID = x.StoreID
			WHERE Stores.StoreID is null
				and x.StoreID is not null
		)
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! Some store not find in the table.'
		GOTO ErrorReturn
	END

	IF EXISTS 
		(
			SELECT 1
			FROM @x AS x
			left join Products
				on Products.ProductID = x.ProductID
			WHERE Products.ProductID is null
				and x.ProductID is not null		
		)
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! Some Products not find in the table.'
		GOTO ErrorReturn
	END

	IF EXISTS 
		(
			SELECT 1
			FROM @X AS x
			WHERE ISNULL(Price,0) <= 0
		)
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! Some ProductPrice could not be empty or negative.'
		GOTO ErrorReturn
	END

---------------------------------------
--
---------------------------------------
	IF @isPriceReplace = 1
		BEGIN
			BEGIN TRY
				UPDATE ProductPrices
				SET ProductPrice = x.Price
				FROM ProductPrices
				JOIN @x AS X
					ON X.ProductID = ProductPrices.ProductID
				WHERE x.StoreID IS NULL


				UPDATE ProductPrices
				SET ProductPrice = x.Price
				FROM ProductPrices
				JOIN @x AS X
					ON X.ProductID = ProductPrices.ProductID
					AND x.StoreID = ProductPrices.StoreID 
				WHERE x.StoreID IS NOT NULL

			END TRY
			BEGIN CATCH
				SET @UserMsg = ISNULL(@UserMsg + ' | ','') + ERROR_MESSAGE()
				SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! ProductPrice dont updated.'
				GOTO ErrorReturn
			END CATCH
		END
---------------------------------------
--
---------------------------------------
	BEGIN TRY
		--add price for product on all stores (StoreID is null in XML)
		--Product and stores not having price
		INSERT INTO ProductPrices(ProductID,StoreID,ProductPrice)
		SELECT X.ProductID,Stores.StoreID,x.Price
		FROM @x AS X
		CROSS APPLY	Stores
		LEFT JOIN ProductPrices
			ON ProductPrices.ProductID = X.ProductID
			AND ProductPrices.StoreID = Stores.StoreID
		WHERE x.StoreID IS NULL
			AND ProductPrices.ProductPriceID IS NULL

		--add price for product on stores (StoreID is not null in XML)
		--Product and stores not having price
		INSERT INTO ProductPrices(ProductID,StoreID,ProductPrice)
		SELECT X.ProductID,Stores.StoreID,x.Price
		FROM @x AS X
		join Stores
			on Stores.StoreID = x.StoreID
		LEFT JOIN ProductPrices
			ON ProductPrices.ProductID = X.ProductID
			AND ProductPrices.StoreID = Stores.StoreID
		WHERE ProductPrices.ProductPriceID IS NULL
	END TRY
	BEGIN CATCH
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + ERROR_MESSAGE()
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! Products didnt add prices.'
		GOTO ErrorReturn
	END CATCH
---------------------------------------
--
---------------------------------------
	SET @UserMsg = ISNULL(@UserMsg + ' | ','') +  'Products add prices'
---------------------------------------
--
---------------------------------------
NormalReturn:
	IF (@TranCheck = 0) COMMIT TRAN
	RETURN	0 
ErrorReturn:
	IF (@@TRANCOUNT > 0)
	BEGIN
		if @TranCheck = 0 ROLLBACK TRAN 
		ELSE ROLLBACK TRAN @TranName
	END	
	RETURN	100
END
GO

CREATE PROCEDURE [dbo].[doc_ProductPrices_Update]
	(
		@ProductPriceID INT
		,@ProductPrice MONEY
		,@UserMsg VARCHAR(256) NULL output
	)
AS
BEGIN

	DECLARE @TranCheck		BIT
	DECLARE @TranName		SYSNAME

	SET @UserMsg	=	NULLIF(LTRIM(@UserMsg), '')
	SET @TranCheck	=	CASE WHEN @@TRANCOUNT > 0 or @@OPTIONS & 2 > 0 THEN 1 ELSE 0 END
	SET @TranName 	=	OBJECT_NAME(@@PROCID) + '-' + convert(varchar(10), @@NESTLEVEL)

	IF @TranCheck = 0 BEGIN TRAN ELSE SAVE TRAN @TranName
---------------------------------------
--
---------------------------------------	
	DECLARE @ProductName varchar(128)
	DECLARE @StoreName varchar(128)

	IF NOT EXISTS (SELECT 1 FROM ProductPrices WHERE ProductPriceID = @ProductPriceID)
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! ProductPriceID [' + Convert(Varchar(20),@ProductPriceID) + '] could not found in the table.'
		GOTO ErrorReturn
	END

	IF ISNULL(@ProductPrice,0) <= 0
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! @ProductPrice could not be empty or negative.'
		GOTO ErrorReturn
	END

	SELECT @ProductName = Products.ProductName
		,@StoreName = Stores.StoreName
	FROM ProductPrices
	JOIN Products
		ON Products.ProductID = ProductPrices.ProductID
	JOIN Stores
		ON Stores.StoreID = ProductPrices.StoreID
	WHERE ProductPrices.ProductPriceID = @ProductPriceID
---------------------------------------
--
---------------------------------------

	BEGIN TRY
		UPDATE ProductPrices
		SET ProductPrice = @ProductPrice
		FROM ProductPrices 
		WHERE ProductPriceID = @ProductPriceID

		SET @UserMsg = ISNULL(@UserMsg + ' | ','') +  'Product [' + @ProductName + '] on store [' + @StoreName + ']  update price [' + convert(varchar(30),@ProductPrice) + '].'
	END TRY
	BEGIN CATCH
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + ERROR_MESSAGE()
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! ProductPrices didnt updated.'
		GOTO ErrorReturn
	END CATCH
---------------------------------------
--
---------------------------------------
NormalReturn:
	IF (@TranCheck = 0) COMMIT TRAN
	RETURN	0 
ErrorReturn:
	IF (@@TRANCOUNT > 0)
	BEGIN
		if @TranCheck = 0 ROLLBACK TRAN 
		ELSE ROLLBACK TRAN @TranName
	END	
	RETURN	100
END
GO

CREATE PROCEDURE [dbo].[doc_ProductPrices_Get]
	(
		@ProductPriceID INT NULL
		,@StoreID int NULL
		,@ProductID int NULL
		,@isEmptyPrice bit = 0
	)
AS
BEGIN
	SELECT
		 ProductPrices.ProductPriceID
		,Products.ProductID
		,Products.ProductName
		,ProductTypes.ProductTypeID
		,ProductTypes.ProductTypeName
		,Stores.StoreID
		,Stores.StoreName
		,ProductPrices.ProductPrice
		,Cities.CityID
		,Cities.CityName
	FROM Products
	JOIN ProductTypes
		ON ProductTypes.ProductTypeID = Products.ProductTypeID
	CROSS JOIN Stores
	LEFT JOIN ProductPrices
		ON ProductPrices.ProductID = Products.ProductID
		AND ProductPrices.StoreID = Stores.StoreID
	LEFT JOIN Cities
		ON Cities.CityID = Stores.CityID
	WHERE ProductPrices.ProductPriceID = @ProductPriceID
		OR 
			(
				@ProductPriceID IS NULL
				AND (@ProductID IS NULL OR Products.ProductID = @ProductID)
				AND (@StoreID IS NULL OR ProductPrices.StoreID = @StoreID)
				AND (@isEmptyPrice = 0 OR ProductPrices.ProductPriceID IS NULL )
			)
END
GO

CREATE PROCEDURE [dbo].[doc_ProductPrices_Delete]
	(
		@ProductPriceID INT
		,@UserMsg VARCHAR(256) NULL output
	)
AS
BEGIN

	DECLARE @TranCheck		BIT
	DECLARE @TranName		SYSNAME

	SET @UserMsg	=	NULLIF(LTRIM(@UserMsg), '')
	SET @TranCheck	=	CASE WHEN @@TRANCOUNT > 0 or @@OPTIONS & 2 > 0 THEN 1 ELSE 0 END
	SET @TranName 	=	OBJECT_NAME(@@PROCID) + '-' + convert(varchar(10), @@NESTLEVEL)

	IF @TranCheck = 0 BEGIN TRAN ELSE SAVE TRAN @TranName
---------------------------------------
--
---------------------------------------	
	IF NOT EXISTS (SELECT 1 FROM ProductPrices WHERE ProductPriceID = @ProductPriceID)
	BEGIN
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! ProductPriceID [' + Convert(Varchar(20),@ProductPriceID) + '] could not found in the table.'
		GOTO ErrorReturn
	END
---------------------------------------
--
---------------------------------------

	BEGIN TRY
		DELETE FROM ProductPrices 
		WHERE ProductPriceID = @ProductPriceID

		SET @UserMsg = ISNULL(@UserMsg + ' | ','') +  'ProductPriceID [' + convert(varchar(20),@ProductPriceID) + '] was deleted'
	END TRY
	BEGIN CATCH
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + ERROR_MESSAGE()
		SET @UserMsg = ISNULL(@UserMsg + ' | ','') + 'Error! ProductPrices didnt deleted.'
		GOTO ErrorReturn
	END CATCH
---------------------------------------
--
---------------------------------------
NormalReturn:
	IF (@TranCheck = 0) COMMIT TRAN
	RETURN	0 
ErrorReturn:
	IF (@@TRANCOUNT > 0)
	BEGIN
		if @TranCheck = 0 ROLLBACK TRAN 
		ELSE ROLLBACK TRAN @TranName
	END	
	RETURN	100
END
GO
