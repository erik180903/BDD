CREATE DATABASE practicaPE
USE practicaPE

SELECT * INTO Order_Header FROM AdventureWorks2019.Sales.SalesOrderHeader
SELECT * INTO Order_Detail FROM AdventureWorks2019.Sales.SalesOrderDetail
SELECT * INTO Customer FROM AdventureWorks2019.Sales.Customer
SELECT * INTO Sales_Territory FROM AdventureWorks2019.Sales.SalesTerritory
SELECT * INTO Product FROM AdventureWorks2019.Production.Product
SELECT * INTO Product_Category FROM AdventureWorks2019.Production.ProductCategory
SELECT * INTO Product_Subcategory FROM AdventureWorks2019.Production.ProductSubcategory
SELECT 
    BusinessEntityID,
    PersonType,
    NameStyle,
    Title,
    FirstName,
    MiddleName,
    LastName,
    Suffix,
    EmailPromotion,
    CAST(AdditionalContactInfo AS NVARCHAR(MAX)) AS AdditionalContactInfo,
    CAST(Demographics AS NVARCHAR(MAX)) AS Demographics,
    rowguid,
    ModifiedDate
INTO Person
FROM AdventureWorks2019.Person.Person;


/*
	1. Listar el producto más vendido de cada una de las categorías registradas
*/

-- Indices propuestos
CREATE CLUSTERED INDEX CI_Product_ProductID ON Product (ProductID);
CREATE CLUSTERED INDEX CI_OrderDetail_ProductID ON Order_Detail (ProductID);
CREATE NONCLUSTERED INDEX NCI_ProductSubcategory_ProductSubcategoryID ON Product_Subcategory (ProductSubcategoryID);

DROP INDEX CI_OrderDetail_ProductID ON Order_Detail;

WITH PCS AS
(
	SELECT PC.ProductID, PC.ProductCategoryID, SUM(OD.OrderQty) AS Sales
	FROM (
		SELECT P.ProductID, PSC.ProductCategoryID
		FROM Product AS P
		JOIN Product_Subcategory AS PSC
		ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
	) AS PC
	JOIN Order_Detail AS OD
	ON PC.ProductID = OD.ProductID
	GROUP BY PC.ProductID, PC.ProductCategoryID
)
SELECT T2.ProductCategoryID, T2.ProductID, T2.Sales
FROM (
	SELECT PCS.ProductCategoryID, MAX(PCS.Sales) AS Sales
	FROM PCS
	GROUP BY PCS.ProductCategoryID
) AS T1
JOIN PCS AS T2
ON T1.ProductCategoryID = T2.ProductCategoryID AND T1.Sales = T2.Sales;

/*
	2. Listar el nombre de los clientes con más ordenes por cada uno de los territorios registrados
*/

-- Indices propuestos
create nonclustered INDEX INC_person_businessentityID ON person(businessentityID) include (FirstName,LastName);
create nonclustered INDEX INC_order_header_territory_customer ON Order_Header (TerritoryID,CustomerID);
create nonclustered INDEX INC_customer_customerID ON Customer (customerID);

WITH OrdenesPorCliente AS (
    SELECT
        OH.TerritoryID,
        OH.CustomerID,
        COUNT(*) AS TotalOrdenes
    FROM Order_Header AS OH
    GROUP BY OH.TerritoryID, OH.CustomerID
),
MaxOrdenesPorTerritorio AS (
    SELECT
        TerritoryID,
        MAX(TotalOrdenes) AS MaxOrdenes
    FROM OrdenesPorCliente
    GROUP BY TerritoryID
),
ClientesTop AS (
    SELECT
        opc.TerritoryID,
        opc.CustomerID,
        opc.TotalOrdenes
    FROM OrdenesPorCliente opc
    JOIN MaxOrdenesPorTerritorio mop
        ON opc.TerritoryID = mop.TerritoryID AND opc.TotalOrdenes = mop.MaxOrdenes
)
SELECT
    ct.TerritoryID,
    p.FirstName + ' ' + p.LastName AS Cliente,
    C.CustomerID,
    ct.TotalOrdenes
FROM ClientesTop ct
JOIN Customer C ON ct.CustomerID = C.CustomerID
JOIN Person P ON C.PersonID = P.BusinessEntityID

/*
	3. Listar datos generales de las ordenes que tengan al menos los mismos productos de la orden con SalesOrderID = 43676
*/

-- Indices propuestos
CREATE NONCLUSTERED INDEX IDX_OrderDetail_SalesOrderID
ON Order_Detail(SalesOrderID);

SELECT DISTINCT Salesorderid
FROM Order_Detail AS OD	
WHERE NOT EXISTS
				(
					SELECT *
					FROM (SELECT productid
					from Order_Detail 
					where salesorderid=43676) as P
					WHERE NOT EXISTS
								(
									SELECT *
									FROM Order_Detail  AS OD2
									WHERE OD.salesorderid = OD2.salesorderid
									AND (OD2.productid = P.productid)
								)
				);
