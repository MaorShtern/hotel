/*
Use Master
GO
Drop Database Final_Project
GO
*/

CREATE DATABASE Final_Project  
COLLATE Hebrew_CI_AS
GO

Use Final_Project 
GO


-- יצירת טבלאות
Create Table TypeOfEmployes
(
	WorkerCode Int Not Null,
	Description Nvarchar(50),
	Constraint PK_WorkerCode Primary Key (WorkerCode),
)
GO

Create Table TypesOfCustomers
(
	CustomersTypes int not null,
	Description Nvarchar(30) not null,
	Constraint PK_CustomersTypes Primary Key (CustomersTypes)
)
go

Create Table Employes
(
	EmployeeID int not null,
	Employee_Name Nvarchar(50) not null,
	WorkingStatus Nvarchar(30) not null,
	WorkerCode int not null,
	HourlyWage int not null,
	Constraint PK_EmployeeID Primary Key (EmployeeID),
	constraint fk_WorkerCode foreign key(WorkerCode) references TypeOfEmployes(WorkerCode)
)
go

Create Table Tasks
(
	TasksNumber int not null,
	Description Nvarchar(100) not null,
	workerID int not null,
	TaskStatus Nvarchar(30) not null,
	Constraint PK_TasksNumber Primary Key (TasksNumber),
	constraint fk_workerID foreign key(workerID) references Employes(EmployeeID)
)
go


Create Table Rooms
(
	RoomNumber int not null,
	RoomType Nvarchar(30) not null,
	RoomStatus Nvarchar(30) not null,
	Constraint PK_RoomNumber Primary Key (RoomNumber)
)
go


create Table Customers
(
	Customers_ID int not null,
	CustomersType int not null,
	FirstName Nvarchar(30) not null,
	LastName Nvarchar(30) not null,
	Email Nvarchar(60),
	PhoneNumber int,
	Constraint PK_Customers_ID Primary Key (Customers_ID),
	constraint fk_CustomersType foreign key(CustomersType) references TypesOfCustomers(CustomersTypes)
)
go

create Table RoomsForTheCustomer
(
	RoomNumber int not null,
	CustomerID int not null,
	BillingDetails Nvarchar(60) not null,
	Constraint PK_RoomNumber1 Primary Key (RoomNumber,CustomerID),
	constraint fk_RoomNumber foreign key(RoomNumber) references Rooms(RoomNumber),
	constraint fk_CustomerID foreign key(CustomerID) references Customers(Customers_ID)
)
go


Create Table Products
(
	ProductNumber int not null,
	Description Nvarchar(100),
	PricePerUnit int not null,
	Constraint PK_ProductNumber Primary Key (ProductNumber)
)
go

Create Table Bill
(
	BillNumber int not null,
	RoomNumber int not null,
	Customers_ID int not null,
	EntryDate date not null,
	ExitDate date null,
	ProductNumber int,
	PurchaseDate date,
	PurchasePrice int,
	Constraint PK_BillNumber Primary Key (BillNumber),
	constraint fk_Customers_ID foreign key(Customers_ID) references Customers(Customers_ID),
	constraint fk_ProductNumber foreign key(ProductNumber) references Products(ProductNumber)
)
go

-- הכנסת ערכים לטבלאות
Insert [dbo].[TypeOfEmployes] ([WorkerCode], [Description]) Values (1,'Manager')
Insert [dbo].[TypeOfEmployes] ([WorkerCode], [Description]) Values (2,'Waiter')
Insert [dbo].[TypeOfEmployes] ([WorkerCode], [Description]) Values (3,'Receptionist')
Insert [dbo].[TypeOfEmployes] ([WorkerCode], [Description]) Values (4,'Room service')
go

Insert  [dbo].[Products] ([ProductNumber],[Description],[PricePerUnit] ) 
Values (123,'A large bottle of cola', 20)
Insert  [dbo].[Products] ([ProductNumber],[Description],[PricePerUnit] ) 
Values (124,'Coated', 46)
Insert  [dbo].[Products] ([ProductNumber],[Description],[PricePerUnit] ) 
Values (125,'A diving watch', 200)
Insert  [dbo].[Products] ([ProductNumber],[Description],[PricePerUnit] ) 
Values (126,'A Towel', 15)
go

Insert [dbo].[Employes] ([EmployeeID],[Employee_Name],[WorkingStatus],[WorkerCode],[HourlyWage]) 
Values (111,'David Ben','on duty',1,40)
Insert [dbo].[Employes] ([EmployeeID],[Employee_Name],[WorkingStatus],[WorkerCode],[HourlyWage]) 
Values (222,'Ben Shalom','on duty',2,34)
Insert [dbo].[Employes] ([EmployeeID],[Employee_Name],[WorkingStatus],[WorkerCode],[HourlyWage]) 
Values (333,'Mor Aviv','not on duty',3,35)
Insert [dbo].[Employes] ([EmployeeID],[Employee_Name],[WorkingStatus],[WorkerCode],[HourlyWage]) 
Values (444,'Han Meser','On duty',4,35)
go


Insert [dbo].[Tasks] ([TasksNumber],[Description],[workerID], [TaskStatus] ) 
Values (1,'Room 354 must be cleaned', 444, 'need to do')
Insert [dbo].[Tasks] ([TasksNumber],[Description],[workerID], [TaskStatus] ) 
Values (2,'Table 3 ordered 2 more drinking bottles', 222, 'done')
Insert [dbo].[Tasks] ([TasksNumber],[Description],[workerID], [TaskStatus] ) 
Values (3,'A customer asks to have Room 354 arranged for him', 444, 'need to do')
go


Insert [dbo].[Rooms] ([RoomNumber], [RoomType],[RoomStatus]) Values (150,'Single','not available')
Insert [dbo].[Rooms] ([RoomNumber], [RoomType],[RoomStatus]) Values (151,'Single','available')
Insert [dbo].[Rooms] ([RoomNumber], [RoomType],[RoomStatus]) Values (152,'Double','available')
Insert [dbo].[Rooms] ([RoomNumber], [RoomType],[RoomStatus]) Values (153,'Double','not available')
Insert [dbo].[Rooms] ([RoomNumber], [RoomType],[RoomStatus]) Values (154,'Suite','not available')
go


Insert [dbo].[TypesOfCustomers] ([CustomersTypes],[Description]) 
Values (1,'Regular customer')
Insert [dbo].[TypesOfCustomers] ([CustomersTypes],[Description]) 
Values (2,'Returning customer')
Insert [dbo].[TypesOfCustomers] ([CustomersTypes],[Description]) 
Values (3,'VIP')
go


Insert [dbo].[Customers] ([Customers_ID], [CustomersType], [FirstName], [LastName],[Email],[PhoneNumber]) 
Values (3333,1,'Ben','Eren','BEN@gmail.com',0536491578)
Insert [dbo].[Customers] ([Customers_ID], [CustomersType], [FirstName], [LastName],[Email],[PhoneNumber]) 
Values (4444,2,'Shalom','Maeir','Shalom@gmail.com',0506489712)
Insert [dbo].[Customers] ([Customers_ID], [CustomersType], [FirstName], [LastName],[Email],[PhoneNumber]) 
Values (5555,3,'Haim','Yona','Haim@gmail.com',0541236897)
go


Insert [dbo].[RoomsForTheCustomer] ([RoomNumber], [CustomerID], [BillingDetails]) 
Values (150,3333,'Credit')
Insert [dbo].[RoomsForTheCustomer] ([RoomNumber], [CustomerID], [BillingDetails]) 
Values (153,4444,'Credit')
Insert [dbo].[RoomsForTheCustomer] ([RoomNumber], [CustomerID], [BillingDetails]) 
Values (154,5555,'Cash')
go



Insert [dbo].[Bill] ([BillNumber],[RoomNumber],[Customers_ID],[EntryDate],
[ProductNumber],[PurchaseDate],[PurchasePrice]) 
Values (110,150,3333,'03/20/2010',123,'3/20/2010',700)
Insert [dbo].[Bill] ([BillNumber],[RoomNumber],[Customers_ID],[EntryDate],[ExitDate],
[ProductNumber],[PurchaseDate],[PurchasePrice]) 
Values (111,151,4444,'03/20/2010','3/23/2010',124,'3/21/2010',750)
Insert [dbo].[Bill] ([BillNumber],[RoomNumber],[Customers_ID],[EntryDate],[ExitDate],
[ProductNumber],[PurchaseDate],[PurchasePrice]) 
Values (112,152,5555,'01/05/2000','01/10/2000',125,'01/07/2000',900)
Insert [dbo].[Bill] ([BillNumber],[RoomNumber],[Customers_ID],[EntryDate],[ExitDate],
[ProductNumber],[PurchaseDate],[PurchasePrice]) 
Values (113,153,3333,'08/01/2007','08/15/2007',126,'08/10/2007',1100)
go






