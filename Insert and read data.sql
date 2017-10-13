/*
Backend​ ​/​ ​SQL​ ​Test​ ​task 
 Create​ ​the​ ​DB​ ​/​ ​web​ ​site​ ​for​ ​managing​ ​the​ ​Products,​ ​Stores​ ​and​ ​Prices. 
 1. Manage​ ​Products​ ​page​ ​should​ ​have​ ​the​ ​ability​ ​to​ ​CRUD​ ​Products​ ​(Product​ ​Name:​ ​text, Product​ ​Type:​ ​choices​ ​“Book”,​ ​“Toy”,​ ​“Clothes”).  
 2. “Manage​ ​Stores”:​ ​show​ ​the​ ​list​ ​of​ ​Stores​ ​from​ ​DB.​ ​Optional:​ ​page​ ​should​ ​have​ ​the​ ​ability to​ ​CRUD​ ​Stores​ ​(Store​ ​Name:​ ​text,​ ​City:​ ​text).  
 3. “Product​ ​price​ ​in​ ​Stores”​ ​page​ ​should​ ​allow​ ​to​ ​assign​ ​the​ ​Price​ ​for​ ​the​ ​Product​ ​in​ ​several Stores​ ​at​ ​once,​ ​but​ ​the​ ​price​ ​could​ ​be​
  ​different​ ​in​ ​different​ ​stores.​ ​Nice​ ​to​ ​have:​ ​code​ ​for updating​ ​the​ ​Price​ ​should​ ​be​ ​able​ ​to​ ​handle​ ​hundreds​ ​of​ ​records​ ​in​ ​a​ ​fast​ ​way. 

 The​ ​flow​ ​of​ ​CRUD​ ​operations​ ​should​ ​be​ ​organized​ ​in​ ​the​ ​following​ ​way:​ ​Frontend​ ​<->​ ​API​ ​<-> Stored​ ​Procedure. 

 Use​ ​Exceptions​ ​in​ ​stored​ ​procedures​ ​to​ ​pass​ ​validation​ ​errors​ ​(e.g.​ ​“Product​ ​Name​ ​is​ ​blank”, “Price​ ​cannot​ ​be​ ​0”,​ ​etc)​
  ​back​ ​to​ ​Frontend​ ​via​ ​API. 

 Deliverables: ● SQL​ ​Scripts​ ​that​ ​create​ ​the​ ​needed​ ​tables,​ ​columns,​ ​primary/foreign​ ​keys,​ ​fill​ ​the​ ​tables with​ ​sample​ ​data,​ ​
 stored​ ​procedures​ ​-​ ​must​ ​have ● API​ ​(Node.JS​ ​is​ ​preferable)​ ​-​ ​nice​ ​to​ ​have ● Simple​ ​frontend​ ​created​ ​in​ ​React​ ​(preferable)​ ​
 or​ ​any​ ​other​ ​UI​ ​Framework​ ​-​ ​nice​ ​to​ ​have ● Instructions​ ​about​ ​installation​ ​&​ ​run​ ​-​ ​must​ ​have 
 Please,​ ​provide​ ​us​ ​a​ ​link​ ​to​ ​git​ ​repository​ ​with​ ​test​ ​task. 
 */
------------------------------------------------------------------------------------------------------------------------------
--Insert ProductTypes
------------------------------------------------------------------------------------------------------------------------------
	declare @UserMsg varchar(256),@ErrorCode int

	Exec @ErrorCode = dict_ProductTypes_Insert @ProductTypeName = 'Book',@UserMsg = @UserMsg output select @ErrorCode, @UserMsg
	go
	declare @UserMsg varchar(256),@ErrorCode int

	Exec @ErrorCode = dict_ProductTypes_Insert @ProductTypeName = 'Toy',@UserMsg = @UserMsg output  select @ErrorCode, @UserMsg
	go
	declare @UserMsg varchar(256),@ErrorCode int

	Exec @ErrorCode = dict_ProductTypes_Insert @ProductTypeName = 'Clothes',@UserMsg = @UserMsg output select @ErrorCode, @UserMsg
	go
	--get ProductTypes
	Exec dict_ProductTypes_Get @ProductTypeID = null,@SearchStr = null
	go
------------------------------------------------------------------------------------------------------------------------------
--Insert New Products
------------------------------------------------------------------------------------------------------------------------------
	declare @UserMsg varchar(256)
	declare @ErrorCode int

	Exec @ErrorCode = doc_Products_Xml_Insert @XML = 
					'<Root>
						<A Product="Product_5" ProductTypeID = "3"/>
						<A Product="Product_3" ProductTypeID = "2"/>
					</Root>'
					,@UserMsg = @UserMsg output

	select @ErrorCode, @UserMsg
	go
	--get products
	Exec doc_Products_Get @ProductID = null,@ProductName = null, @ProductTypeID = null
	go
------------------------------------------------------------------------------------------------------------------------------
--Insert new cities
------------------------------------------------------------------------------------------------------------------------------
	declare @UserMsg varchar(256),@ErrorCode int

	Exec @ErrorCode = dict_Cities_Insert @CityName = 'KIEV',@UserMsg = @UserMsg output select @ErrorCode, @UserMsg
	go
	declare @UserMsg varchar(256),@ErrorCode int

	Exec @ErrorCode = dict_Cities_Insert @CityName = 'KHARKOV',@UserMsg = @UserMsg output select @ErrorCode, @UserMsg
	go
	declare @UserMsg varchar(256),@ErrorCode int

	Exec @ErrorCode = dict_Cities_Insert @CityName = 'Nikolaev',@UserMsg = @UserMsg output select @ErrorCode, @UserMsg
	go
	--get Cities
	Exec dict_Cities_Get @CityID = null,@SearchStr = null
	go
------------------------------------------------------------------------------------------------------------------------------
--insert new stores
------------------------------------------------------------------------------------------------------------------------------
	declare @UserMsg varchar(256),@ErrorCode int

	Exec @ErrorCode = dict_Stores_Insert @StoreName = 'KIEV_1',@CityID = 1, @UserMsg = @UserMsg output select @ErrorCode, @UserMsg
	GO
	declare @UserMsg varchar(256),@ErrorCode int

	Exec @ErrorCode = dict_Stores_Insert @StoreName = 'KIEV_2',@CityID = 1, @UserMsg = @UserMsg output select @ErrorCode, @UserMsg
	GO
	declare @UserMsg varchar(256),@ErrorCode int

	Exec @ErrorCode = dict_Stores_Insert @StoreName = 'KHARKOV_1',@CityID = 2, @UserMsg = @UserMsg output select @ErrorCode, @UserMsg
	go
	--get Stores
	EXEC dict_Stores_Get  @StoreID = null,@CityID = null,@SearchStr = null
	go
------------------------------------------------------------------------------------------------------------------------------
--update and insert products prices
------------------------------------------------------------------------------------------------------------------------------
	declare @UserMsg varchar(256)
	declare @ErrorCode int

	Exec @ErrorCode = doc_ProductPrices_XML_Save @XML = 
					'<Root>
						<A ProductID="1" StoreID = "3" Price = "3.44"/>
						<A ProductID="3" StoreID = "2" Price = "6"/>
						<A ProductID="2" Price = "14.56"/>
						<A ProductID="4" Price = "4.23"/>
					</Root>'
					,@isPriceReplace = 1
					,@UserMsg = @UserMsg output

	select @ErrorCode, @UserMsg
	go
------------------------------------------------------------------------------------------------------------------------------
--get products without prices
------------------------------------------------------------------------------------------------------------------------------
EXECUTE doc_ProductPrices_Get @ProductPriceID = NULL
,@StoreID = NULL
,@ProductID = NULL
,@isEmptyPrice = 1

------------------------------------------------------------------------------------------------------------------------------
--get all products and prices
------------------------------------------------------------------------------------------------------------------------------
EXECUTE doc_ProductPrices_Get @ProductPriceID = NULL
,@StoreID = NULL
,@ProductID = NULL
,@isEmptyPrice = 0