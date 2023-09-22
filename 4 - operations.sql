USE BluejackJewelry
GO

-- 1. Display VendorId, VendorName, StaffName, Total Transation (obtained from the total of purchase transaction done by staff) for every purchase transaction which occurs in July and Vendor whose name is more than 1 word.
SELECT mv.VendorID, mv.VendorName, ms.StaffName, [Total Transaction] = COUNT(PurchaseID)
FROM MsVendor mv JOIN PurchaseHeader ph 
ON mv.VendorID = ph.VendorID
JOIN MsStaff ms
ON ph.StaffID = ms.StaffID
WHERE MONTH(PurchaseDate) = 7
AND VendorName LIKE '% %'
GROUP BY mv.VendorID, mv.VendorName, ms.StaffName

-- 2. Display JewelryTypeName and Total Price (obtained from the total amount of sales price times quantity and ends with ' USD') for every type which name contains 'ruby' or 'diamond' and Total Price is greater than 40000.
SELECT mjt.JewelryTypeName, [Total Price] = CONVERT(VARCHAR, SUM(JewelrySalesPrice*SalesQty)) + ' USD'
FROM MsJewelryType mjt JOIN MsJewelry mj 
ON mjt.JewelryTypeID = mj.JewelryTypeID JOIN SalesDetail sd
ON mj.JewelryID = sd.JewelryID 
WHERE mjt.JewelryTypeName LIKE '%ruby%' OR mjt.JewelryTypeName LIKE '%diamond%'
GROUP BY mjt.JewelryTypeName
HAVING SUM(JewelrySalesPrice*SalesQty) > 40000

-- 3.	Display Date (obtained from SalesDate in ‘Mon dd, yyyy’ format), CustomerName, Total Jewelry (obtained from the total number of different jewelry bought by customer), and Total Quantity (obtained from the sum of the quantity of all jewelry) for every customer whose name has more than 10 characters and the transaction occurs in September.
SELECT [Date] = CONVERT(VARCHAR, SalesDate, 107), CustomerName, [Total Jewelry] = COUNT(DISTINCT JewelryID), [Total Quantity] = SUM(SalesQty)
FROM MsCustomer mc JOIN SalesHeader sh
ON mc.CustomerID = sh.CustomerID 
JOIN SalesDetail sd ON 
sh.SalesID = sd.SalesID
WHERE LEN(mc.CustomerName)>10 
AND MONTH(SalesDate) = 9
GROUP BY SalesDate, CustomerName

-- 4.	Display StaffId, StaffName, JewelryName, Total Jewelry (obtained from the total number of different jewelry purchase by staff), Total Price (obtained from the total amount of purchase price times quantity and ends with ' USD') for every transaction handled by a Staff whose gender is Male and Total Jewelry is more than equals 2, then sort the result based on Total Price in Descending.
SELECT ms.StaffID, StaffName, JewelryName,  [Total Jewelry] = COUNT(pd.JewelryID), [Total Price] = CONCAT(SUM(mj.JewelryPurchasePrice*pd.PurchaseQty) , ' USD')
FROM MsStaff ms JOIN PurchaseHeader ph ON ms.StaffID = ph.StaffID JOIN PurchaseDetail pd ON ph.PurchaseID = pd.PurchaseID JOIN MsJewelry mj ON pd.JewelryID = mj.JewelryID
WHERE StaffGender = 'Male'
GROUP BY ms.StaffID, StaffName, JewelryName
HAVING COUNT(pd.JewelryID) >= 2
ORDER BY [Total Price] DESC

-- 5.	Display CustomerName, CustomerEmail, CustomerAddress, JewelryName, and Jewelry Weight (ends with ' gram') for every Customer who buys the jewelry at a maximum JewelrySalesPrice  and Customer Address contains with 'l'  characters, then sort the result based on CustomerName in Ascending order. The duplicate data must be displayed once.
SELECT DISTINCT CustomerName, CustomerEmail, CustomerAddress, JewelryName, [Jewelry Weight] = CONCAT(CAST(JewelryWeight AS VARCHAR), ' gram')
FROM MsCustomer mc JOIN SalesHeader sh ON mc.CustomerID = sh.CustomerID JOIN SalesDetail sd ON sh.SalesID = sd.SalesID JOIN MsJewelry mj ON sd.JewelryID = mj.JewelryID,
(
	SELECT MAX(JewelrySalesPrice) AS maxprice
	FROM MsJewelry
) AS maxtable
WHERE CustomerAddress LIKE '%l%' AND JewelrySalesPrice = maxtable.maxprice
ORDER BY CustomerName ASC

-- 6.	Display VendorName, VendorEmail, VendorPhone, JewelryName, Jewelry Price (obtained from JewelryPurchasePrice and ends with ' USD') for every Vendor who sells the Jewelry at minimum JewelryPurchasePrice and VendorName contains 'n' characters, then sort the result based on VendorName in Descending order.
SELECT DISTINCT VendorName, VendorEmail, VendorPhone, JewelryName, [Jewelry Price] = CONCAT(CAST(JewelryPurchasePrice AS VARCHAR), ' USD')
FROM MsVendor mc JOIN PurchaseHeader sh ON mc.VendorID = sh.VendorID JOIN PurchaseDetail sd ON sh.PurchaseID = sd.PurchaseID JOIN MsJewelry mj ON sd.JewelryID = mj.JewelryID,
(
	SELECT MIN(JewelryPurchasePrice) AS minprice
	FROM MsJewelry
) AS mintable
WHERE VendorName LIKE '%n%' AND JewelryPurchasePrice = mintable.minprice
ORDER BY VendorName DESC

-- 7.	Display Staff ID (obtained from StaffID and replace 'ST' with 'Staff '), StaffName, JewelryName, Total Price (obtained from the total amount of purchase price times quantity and ends with ' USD') for every transaction which quantity is more than the average of all purchase quantity and the transaction occurred in an odd day. Then sort the result based on StaffName in Ascending order
SELECT StaffID = REPLACE(ms.StaffID, SUBSTRING(ms.StaffID, 1,2), 'Staff ') , ms.StaffName , mj.JewelryName , [Total Price] = CONCAT(SUM(mj.JewelryPurchasePrice*pd.PurchaseQty) , ' USD')
FROM MsStaff ms JOIN PurchaseHeader ph
ON ms.StaffID = ph.StaffID 
JOIN PurchaseDetail pd
ON ph.PurchaseID = pd.PurchaseID 
JOIN MsJewelry mj
ON pd.JewelryID = mj.JewelryID ,
(
	SELECT [avg_purchase] = AVG(pd.PurchaseQty)
	FROM PurchaseDetail pd JOIN PurchaseHeader ph
	ON pd.PurchaseID = ph.PurchaseID 
) average
WHERE pd.PurchaseQty > average.avg_purchase AND DATEPART(DAY,ph.PurchaseDate) % 2 = 1
GROUP BY ms.StaffID , ms.StaffName , mj.JewelryName
ORDER BY StaffName ASC


-- 8.	Display StaffId, Staff Name (Obtained by StaffName in Uppercase format), SalesId, and Total Price (obtained from the total amount of sales price times quantity and ends with ' USD’) for every transaction with Total Price is higher than the average Total Price from every sales transaction and a Staff whose name contains 'o' character. Then sort the data based on Total Price in descending format.
SELECT ms.StaffID, [Staff Name] = UPPER(StaffName), sh.SalesID, [Total Price] = CONCAT(SUM(mj.JewelrySalesPrice*sd.SalesQty) , ' USD')
FROM MsStaff ms JOIN SalesHeader sh
ON ms.StaffID = sh.StaffID 
JOIN SalesDetail sd
ON sh.SalesID = sd.SalesID 
JOIN MsJewelry mj 
ON sd.JewelryID = mj.JewelryID,
(
	SELECT AVG(total_price) AS avg_total
	FROM (
		SELECT SUM(JewelrySalesPrice*SalesQty) AS total_price
		FROM SalesDetail sd JOIN MsJewelry mj 
		ON sd.JewelryID = mj.JewelryID 
		GROUP BY sd.SalesID
		) total_table
) average2
WHERE ms.StaffName LIKE '%o%'
GROUP BY ms.StaffID , StaffName , sh.SalesID , avg_total
HAVING SUM(mj.JewelrySalesPrice*sd.SalesQty) > average2.avg_total
ORDER BY [Total Price] DESC


-- 9.	Create a view named [viewStaffSales] to display StaffId, Staff Name (obtained from StaffName in lowercase format), StaffEmail, Total Jewelry Sold (obtained from the total number of different jewelry sold by staff), and Average Quantity (obtained from the average of quantity) for every sales transaction which handled by staff whose name is not more than one word and more than 5 characters.
CREATE VIEW viewStaffSales
AS
SELECT ms.StaffID, [Staff Name] = LOWER(StaffName), StaffEmail, [Total Jewelry Sold] = COUNT(DISTINCT JewelryID), [Average Quantity] = AVG(SalesQty)
FROM MsStaff ms JOIN SalesHeader sh ON ms.StaffID = sh.StaffID JOIN SalesDetail sd ON sh.SalesID = sd.SalesID
WHERE CHARINDEX(' ', StaffName) <=0 AND LEN(StaffName) > 5
GROUP BY ms.StaffID, StaffName, StaffEmail

-- 10.	Create a view named viewVendorPurchase to display VendorId, VendorName, VendorEmail, VendorAddress, Total Jewelry Purchased (obtained from the total number of different jewelry sold by vendor), and Average Quantity (obtained from the average of quantity) for every purchase transaction done by a vendor whose VendorAddress' number is an odd number and the Total Purchased is more than 1.
CREATE VIEW viewVendorPurchase
AS
SELECT mv.VendorID, VendorName, VendorEmail, VendorAddress, [Total Jewelry Purchased] = COUNT(DISTINCT JewelryID), [Average Quantity] = AVG(PurchaseQty)
FROM MsVendor mv JOIN PurchaseHeader ph ON mv.VendorID = ph.VendorID JOIN PurchaseDetail pd ON ph.PurchaseID = pd.PurchaseID
WHERE CONVERT(INT, SUBSTRING(REVERSE(VendorAddress), CHARINDEX(' ', REVERSE(VendorAddress))+1, 1)) % 2 != 0
GROUP BY mv.VendorID, VendorName, VendorEmail, VendorAddress
HAVING COUNT(DISTINCT JewelryID) > 1