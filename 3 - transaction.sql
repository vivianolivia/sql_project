-- Stimulate the transaction process for sales and purchasae transaction
USE BluejackJewelry
GO

INSERT INTO SalesHeader VALUES
('SL016' , 'ST001' , 'CU005' , '2020-05-14'),
('SL017' , 'ST005' , 'CU002' , '2020-06-06'),
('SL018' , 'ST009' , 'CU007' , '2020-08-12'),
('SL019' , 'ST010' , 'CU013' , '2020-08-26'),
('SL020' , 'ST003' , 'CU009' , '2020-09-06')

INSERT INTO PurchaseHeader VALUES
('PU018','ST010','VE002','2020-04-05'),
('PU019','ST006','VE005','2020-06-15'),
('PU020','ST002','VE003','2020-07-22'),
('PU021','ST004','VE009','2020-08-13'),
('PU022','ST007','VE007','2020-10-30')

INSERT INTO PurchaseDetail VALUES
('PU018','JW001',2),
('PU019','JW012',1),
('PU019','JW005',4),
('PU020','JW010',8),
('PU021','JW003',2),
('PU022','JW007',3),
('PU022','JW009',1)

INSERT INTO SalesDetail VALUES
('SL016' , 'JW005' , 8),
('SL017' , 'JW003' , 2),
('SL018' , 'JW010' , 5),
('SL018' , 'JW007' , 4),
('SL019' , 'JW002' , 1),
('SL020' , 'JW008' , 7)