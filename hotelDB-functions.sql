Use Final_Project 
GO

--=====================================================================
---	פרוצדורות (עם פרמטרים של קלט, פלט טבלאות זמניות להחזרת תוצאות
--=====================================================================

--  פרוצדורה המקבלת את ערכי החובה ליצירת עובד והוספתו לטבלה 
create proc AddNewEmploye(@ID int,@name Nvarchar(50), @WorkerCode int, @HourlyWage int )
as
	Insert [dbo].[Employes] ([EmployeeID],[Employee_Name],[WorkingStatus],[WorkerCode],[HourlyWage]) 
	Values (@ID,@name,'not on duty',@WorkerCode,@HourlyWage)
go

exec AddNewEmploye 8888,'maor bbb',2,43
go


--  טבלת עזר
create table ShowRole
(
	EmployeeID int not null,
	Employee_Name Nvarchar(50) not null,
	Description Nvarchar(30),
	HourlyWage int not null
)
go

--  פרוצדורה אשר מחזירה טבלה זמנית על מנת להציג תוצאות בהתאם לבחירת המשתמש
create proc FindEmployes(@Role int)
as
	SELECT dbo.Employes.EmployeeID, dbo.Employes.Employee_Name, dbo.TypeOfEmployes.Description, dbo.Employes.HourlyWage
	FROM     dbo.Employes INNER JOIN
                  dbo.TypeOfEmployes ON dbo.Employes.WorkerCode = dbo.TypeOfEmployes.WorkerCode
	where dbo.Employes.WorkerCode = @Role
go


--  פרוצדורה המוחקת את תוכן טבלת העזר ומכניסה אליה ערכים בהתאם לערך שהמשתמש בחר
create proc ReturnTableOfEmployesByRole(@Role int)
as
	Delete From  ShowRole
	insert dbo.ShowRole (EmployeeID,Employee_Name,Description,HourlyWage)
	exec FindEmployes @Role
go

exec ReturnTableOfEmployesByRole 3
select * from ShowRole
--=====================================================================



--==================================================================
--  לולאות 
--==================================================================

--  לולאת while
create proc Update_Salary 
as
	while (select avg([HourlyWage]) from [dbo].[Employes]) < 100
	begin
		update [dbo].[Employes]
		set [HourlyWage] = [HourlyWage] * 1.5
	end
go

exec  Update_Salary 
select * from [dbo].[Employes]



--  לולאת Cursor 
create proc Update_Products_Discount (@price int , @discount_percentage int)
as
DECLARE @productPrice int
DECLARE db_cursor CURSOR FOR SELECT [PricePerUnit] FROM  [dbo].[Products]
OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @productPrice  

	while @@FETCH_STATUS = 0 
	begin
		update [dbo].[Products]
		set [PricePerUnit] = (@price - (@price * (@discount_percentage / 100)))
		where [PricePerUnit] > @price
		FETCH NEXT FROM db_cursor INTO @productPrice  
	end
CLOSE db_cursor  
DEALLOCATE db_cursor 
go

exec Update_Products_Discount 100,20
go

select * from [dbo].[Products]



--==================================================================
--  פונקציות 
--==================================================================

-- פונקציה סקאלרית
create FUNCTION TaxRate(@productID int ,@amount int)
RETURNS NUMERIC (6,2)
AS
BEGIN
DECLARE @productPrice int
set @productPrice = ( select [PricePerUnit] from [dbo].[Products] where [ProductNumber] = @productID)
  RETURN  
     (  SELECT 
          CASE @amount 
              WHEN 1 THEN @productPrice * @amount * 1.50
              WHEN 2 THEN  @productPrice * @amount *2.0
              WHEN 3 THEN @productPrice * @amount *3.50
          END  )
END  
Go

select dbo.TaxRate(125,2)




--  פונקציה טבלאית
create function Find_Type_Of_Customers_By_Date(@date date)
returns table
as
	return(
	SELECT dbo.Bill.Customers_ID, dbo.Customers.FirstName, dbo.Customers.LastName, dbo.TypesOfCustomers.Description, dbo.Bill.EntryDate
FROM     dbo.Bill INNER JOIN
                  dbo.Customers ON dbo.Bill.Customers_ID = dbo.Customers.Customers_ID INNER JOIN
                  dbo.TypesOfCustomers ON dbo.Customers.CustomersType = dbo.TypesOfCustomers.CustomersTypes
				  where dbo.Bill.EntryDate = @date
GROUP BY dbo.Bill.Customers_ID, dbo.Customers.FirstName, dbo.Customers.LastName, dbo.TypesOfCustomers.Description, dbo.Bill.EntryDate
	)
go

select*from Find_Type_Of_Customers_By_Date('2000-01-05')
go


--==================================================================
--  טרנזקציות וטריגרים 
--==================================================================

--  טרנזקציה
create proc Update_Worker_Code(@workerID int, @Description nvarchar(50))
as
DECLARE @workerDescription int
set @workerDescription = (select [WorkerCode] from [dbo].[TypeOfEmployes] 
							where [Description] = @Description)

	begin TRANSACTION
	update [dbo].[Employes]
	set [WorkerCode] = @workerDescription
	where [EmployeeID] = @workerID
	if(@@ERROR <> 0) 
		BEGIN
		ROLLBACK TRANSACTION -- אם שגיאה בחלק הראשון לא לבצע את הפעולות
		RETURN  -- אם שגיאה בחלק הראשון לצאת לגמרי, לא להמשיך הלאה
	END
	commit TRANSACTION
go

exec Update_Worker_Code 564,Manager
go

drop trigger Attempt_to_enter_incorrect_entry_date
--  טריגרים
create trigger Attempt_to_enter_incorrect_entry_date
	on [dbo].[Bill] for insert
	as
		DECLARE @status date;
        SELECT @status=i.EntryDate FROM inserted i; 
		declare @Date int = ((select(CONVERT(char(12), @status ,112))))
		declare @Current_Date int = ((select(CONVERT(char(12), getDate() ,112))))

		if (@Date != @Current_Date)
		begin
			ROLLBACK transaction
			print 'The [EntryDate] entered in the system is invalid'
		end
	go

select * from [dbo].[Bill]

Insert [dbo].[Bill] ([BillNumber],[RoomNumber],[Customers_ID],[EntryDate],[ExitDate],
[ProductNumber],[PurchaseDate],[PurchasePrice]) 
Values (777,153,5555,'03/12/2023','08/15/2007',126,'08/10/2007',1100)





--==================================================
--	יצירת מסד נתונים ארכיוני ( שימוש במחרוזות )
--==================================================
Set DateFormat DMY
go

IF  EXISTS ( SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID('[dbo].[Create_NewDB]') AND type in ('P', 'PC') )
     DROP  PROC [dbo].[Create_NewDB]
Go


create Proc Create_NewDB  
	@yy int
as
	IF  EXISTS ( SELECT name FROM sys.databases WHERE name = Concat('Final_Project',@yy) )
	Begin
       Declare @sql_dr varchar(100)
       Set @sql_dr = Concat ('DROP DATABASE Final_Project' , @yy)
       Execute (@sql_dr)
    End  
Declare @DbName VarChar (20)
Declare @Sql Varchar (40)
Select @DbName = Concat ('Final_Project' , @yy)
Select @Sql = Concat ('CREATE DATABASE ' , @Dbname)
Execute (@Sql) 
Go

Declare @YY int
Set @yy = 2022
Exec Create_NewDB @yy
Go

create Proc Create_Tbl_NEwDB
     (@tbl nvarchar (50) , @yy varchar(4))
As
    Declare @sql varchar(300)
    Declare @T varchar (50)
    Set @T = 'Final_Project' + @yy +'.dbo.' + @Tbl
    Set @sql = 'Select * Into ' + @T  + ' From Final_Project.dbo.' + @Tbl 
		select @sql
    Execute (@sql) 
Go

Exec Create_Tbl_NEwDB 'Customers', '2022'
Go


IF  EXISTS ( SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[Create_AllTbl_NewDB]'))
     DROP  PROC [dbo].[Create_AllTbl_NewDB]
Go
 create Proc Create_AllTbl_NewDB(@yy varchar(4))
 as
 exec Create_NewDB @yy

Declare @table_name Varchar(50)
Declare all_tables Cursor  --  Cursor  הכרזה על משתנה מסוג 
For Select name from sysobjects where type = 'U' order by name
For read only
Open all_tables                 --  Cursor לפתוח את ה 
---
Fetch next from all_tables   into @table_name      -- להביא רשומה ראשונה לתוך משתנה עזר
While @@fetch_status=0
Begin
   Set @Table_name = Concat ('[',@table_name,']')
   Print @table_name
        Exec Create_Tbl_NEwDB  @table_name , @yy    -- הפעלת פרוצדורה להעתקת טבלה
        Fetch next from all_tables  into @table_name        -- להביא רשומה הבאה
   End
Close all_tables 
Deallocate all_tables 
Go

Declare @yy int
   set @yy= YEAR(getdate())
   exec Create_AllTbl_NewDB @yy
   go


 
		
	
--==================================================
--  גיבויים ושיחזורים ---
--==================================================

BACKUP DATABASE Final_Project
TO DISK = 'C:\BDB-FinalSemA\Final_Project.bak'
with format
GO

-- להתאים את הפרוצדורות של ה-cmd
-- שיהיה מותקנות לSQL
EXEC sp_configure 'show advanced options', 1
RECONFIGURE
GO
sp_configure 'xp_cmdshell', '1' 
RECONFIGURE with override
Go

--  שיחזור
USE master
GO
IF  EXISTS (SELECT name FROM sys.databases WHERE name = N'Final_Project')
   DROP DATABASE Final_Project
GO
RESTORE DATABASE Final_Project
FROM DISK = 'C:\BDB-FinalSemA\Final_Project.bak'
GO
--==================================================


--==================================================
-- -	קשר לאקסל ( ייבוא, ייצוא )
--==================================================
Use Final_Project
go 

   -- יצור תיקייה
Declare @table_name  varchar(50) 
Declare @path  varchar(50)
Declare @file_name  varchar(50)
Declare @command  varchar(120)
Declare @dir  varchar(120) 
Set @table_name = 'Employes'
Set @path = 'C:\BDB-FinalSemA\' + db_name() + '\'
Set @file_name = @path +  @table_name + '.xls'
Set @dir = 'MD ' + @path
EXEC  xp_cmdshell  @dir
Set @command = 'bcp ' + db_name() + '.dbo.' + @table_name +  ' out "' + @file_name + '" -c -N -w -S.\SQLEXPRESS -T '
go


create proc Export_To_Xel(@table_name varchar(50))
as
	Declare @path  varchar(50)
	Declare @file_name  varchar(50)
	Declare @command  varchar(120)
	Declare @dir  varchar(120) 
	Set @path = 'C:\BDB-FinalSemA\Final_Project\'
	Set @file_name = @path +  @table_name + '.csv'
	Set @dir = 'MD ' + @path
	EXEC  xp_cmdshell  @dir
	Set @command = 'bcp ' + db_name() + '.dbo.' + @table_name +  ' out "' + @file_name + '" -c -N -w -S.\SQLEXPRESS -T '
	EXEC  master..xp_cmdshell   @command
go


create proc Export_All_Table_To_Xel
as
	Declare @table_name Varchar(50)
	Declare all_tables Cursor    -- Cursor הכרזה על משתנה מסוג 
	For Select name from sysobjects where type = 'U' order by name
	For read only
	Open all_tables              --   Cursor לפתוח את ה 
	---
	Fetch next  from all_tables   into @table_name  -- להביא רשומה ראשונה לתוך משתנה עזר
	While @@fetch_status=0
		Begin
			exec Export_To_Xel @table_name
			Print @table_name
			Fetch next  from all_tables  into @table_name  -- להביא את הרשומה הבאה
		End
	Close all_tables 
	Deallocate all_tables 
GO

exec Export_All_Table_To_Xel
go


BULK INSERT  [dbo].[Bill]   
      FROM 'C:\BDB-FinalSemA\Final_Project\Bill.csv'   
      WITH 
       ( 
		CODEPAGE = 'ACP',  -- לאפשר עברית
		FIRSTROW = 2 ,  -- שורת כותרות
		MAXERRORS = 0 , -- לא לאפשר שגיאות
        FIELDTERMINATOR = ',', -- מפריד בין שדות
        ROWTERMINATOR = '\n'  -- new line
       )
   GO
   BULK INSERT  [dbo].[Customers]  
      FROM 'C:\BDB-FinalSemA\Final_Project\Customers.csv'   
      WITH 
       ( 
		CODEPAGE = 'ACP',  -- לאפשר עברית
		FIRSTROW = 2 ,  -- שורת כותרות
		MAXERRORS = 0 , -- לא לאפשר שגיאות
        FIELDTERMINATOR = ',', -- מפריד בין שדות
        ROWTERMINATOR = '\n'  -- new line
       )
   GO
    BULK INSERT  [dbo].[Employes] 
      FROM 'C:\BDB-FinalSemA\Final_Project\Employes.csv'   
      WITH 
       ( 
		CODEPAGE = 'ACP',  -- לאפשר עברית
		FIRSTROW = 2 ,  -- שורת כותרות
		MAXERRORS = 0 , -- לא לאפשר שגיאות
        FIELDTERMINATOR = ',', -- מפריד בין שדות
        ROWTERMINATOR = '\n'  -- new line
       )
   GO

    BULK INSERT  [dbo].[Products]
      FROM 'C:\BDB-FinalSemA\Final_Project\Products.csv'   
      WITH 
       ( 
		CODEPAGE = 'ACP',  -- לאפשר עברית
		FIRSTROW = 2 ,  -- שורת כותרות
		MAXERRORS = 0 , -- לא לאפשר שגיאות
        FIELDTERMINATOR = ',', -- מפריד בין שדות
        ROWTERMINATOR = '\n'  -- new line
       )
   GO
    BULK INSERT  [dbo].[Rooms]
      FROM 'C:\BDB-FinalSemA\Final_Project\Rooms.csv'   
      WITH 
       ( 
		CODEPAGE = 'ACP',  -- לאפשר עברית
		FIRSTROW = 2 ,  -- שורת כותרות
		MAXERRORS = 0 , -- לא לאפשר שגיאות
        FIELDTERMINATOR = ',', -- מפריד בין שדות
        ROWTERMINATOR = '\n'  -- new line
       )
   GO
   BULK INSERT  [dbo].[RoomsForTheCustomer]
      FROM 'C:\BDB-FinalSemA\Final_Project\RoomsForTheCustomer.csv'   
      WITH 
       ( 
		CODEPAGE = 'ACP',  -- לאפשר עברית
		FIRSTROW = 2 ,  -- שורת כותרות
		MAXERRORS = 0 , -- לא לאפשר שגיאות
        FIELDTERMINATOR = ',', -- מפריד בין שדות
        ROWTERMINATOR = '\n'  -- new line
       )
   GO
    BULK INSERT [dbo].[ShowRole]
      FROM 'C:\BDB-FinalSemA\Final_Project\ShowRole.csv'   
      WITH 
       ( 
		CODEPAGE = 'ACP',  -- לאפשר עברית
		FIRSTROW = 2 ,  -- שורת כותרות
		MAXERRORS = 0 , -- לא לאפשר שגיאות
        FIELDTERMINATOR = ',', -- מפריד בין שדות
        ROWTERMINATOR = '\n'  -- new line
       )
   GO
   BULK INSERT [dbo].[Tasks]
      FROM 'C:\BDB-FinalSemA\Final_Project\Tasks.csv'   
      WITH 
       ( 
		CODEPAGE = 'ACP',  -- לאפשר עברית
		FIRSTROW = 2 ,  -- שורת כותרות
		MAXERRORS = 0 , -- לא לאפשר שגיאות
        FIELDTERMINATOR = ',', -- מפריד בין שדות
        ROWTERMINATOR = '\n'  -- new line
       )
   GO
   BULK INSERT [dbo].[TypeOfEmployes]
      FROM 'C:\BDB-FinalSemA\Final_Project\TypeOfEmployes.csv'   
      WITH 
       ( 
		CODEPAGE = 'ACP',  -- לאפשר עברית
		FIRSTROW = 2 ,  -- שורת כותרות
		MAXERRORS = 0 , -- לא לאפשר שגיאות
        FIELDTERMINATOR = ',', -- מפריד בין שדות
        ROWTERMINATOR = '\n'  -- new line
       )
   GO
   BULK INSERT [dbo].[TypesOfCustomers]
      FROM 'C:\BDB-FinalSemA\Final_Project\TypesOfCustomers.csv'   
      WITH 
       ( 
		CODEPAGE = 'ACP',  -- לאפשר עברית
		FIRSTROW = 2 ,  -- שורת כותרות
		MAXERRORS = 0 , -- לא לאפשר שגיאות
        FIELDTERMINATOR = ',', -- מפריד בין שדות
        ROWTERMINATOR = '\n'  -- new line
       )
   GO


--==================================================
-- -	-	אבטחת מידע ( מסיכות, כניסות, תפקידים, משתמשים, הרשאות )
--==================================================

--  הצפנות
create table LoginEmployes
(
	ID int not null,
	Password NVARCHAR(100)  ,
	Encrypt_Pass varbinary(max) ,
	Constraint PK_ID Primary Key (ID)
)

Create Master Key encryption by password = 'MaorIrit1'
go
Create certificate MyCert with subject = 'MyCertSubj' 
go
Create symmetric key MyKey with algorithm=AES_256 encryption
   by certificate MyCert; 
go
Select * From sys.symmetric_keys 
go

create trigger PasswordEncryption
on [dbo].[LoginEmployes] for insert
as
	Open symmetric key MyKey decryption by certificate MyCert 
	Update [dbo].[LoginEmployes]
	SET [Encrypt_Pass] =  EncryptByKey(Key_GUID('MyKey'),[Password])
go

Insert [dbo].[LoginEmployes] ([ID],[Password] ,[Encrypt_Pass]) 
Values (111,'123456', null)
Insert [dbo].[LoginEmployes] ([ID],[Password] ,[Encrypt_Pass]) 
Values (222,'645987', null)
Insert [dbo].[LoginEmployes] ([ID],[Password] ,[Encrypt_Pass]) 
Values (333,'316498', null)
Insert [dbo].[LoginEmployes] ([ID],[Password] ,[Encrypt_Pass]) 
Values (444,'123648', null)

select * from [LoginEmployes]


--  כניסות, תפקידים, משתמשים, הרשאות

CREATE LOGIN  maor  with Password ='123456' , CHECK_POLICY = OFF
CREATE LOGIN  irit  with Password ='123456' , CHECK_POLICY = OFF
CREATE LOGIN  Mali  with Password ='MMMM' , CHECK_POLICY = OFF
CREATE LOGIN  Loren  with Password ='LLLL' , CHECK_POLICY = OFF
CREATE LOGIN  Ben  with Password ='BBBB' , CHECK_POLICY = OFF
CREATE LOGIN  Noam  with Password ='NNNN' , CHECK_POLICY = OFF
GO

Use [Final_Project]
EXEC sp_grantdbaccess 'maor','maor_M'
EXEC sp_grantdbaccess 'irit','irit_I'
EXEC sp_grantdbaccess 'Mali','Mali_M'
EXEC sp_addrole 'Managers'

EXEC sp_grantdbaccess 'Loren','Loren_L'
EXEC sp_addrole 'Customers'

EXEC sp_grantdbaccess 'Ben','Ben_B'
EXEC sp_grantdbaccess 'Noam','Noam_N'
EXEC sp_addrole 'Receipts'


EXEC sp_addrolemember 'Managers','maor_M'
EXEC sp_addrolemember 'Managers','irit_I'
EXEC sp_addrolemember 'Managers','Mali_M'
EXEC sp_addrolemember 'Customers','Loren_L'
EXEC sp_addrolemember 'Receipts','Ben_B'
EXEC sp_addrolemember 'Receipts','Noam_N'
GO
sp_helpuser
GO


GRANT SELECT,INSERT, UPDATE, Delete
on [dbo].[Bill]
TO [Managers]  WITH GRANT OPTION
GRANT SELECT,INSERT, UPDATE, Delete
on [dbo].[Customers]
TO [Managers]  WITH GRANT OPTION
GRANT SELECT,INSERT, UPDATE, Delete
on [dbo].[Employes]
TO [Managers]  WITH GRANT OPTION
GRANT SELECT,INSERT, UPDATE, Delete
on [dbo].[LoginEmployes]
TO [Managers]  WITH GRANT OPTION
GRANT SELECT,INSERT, UPDATE, Delete
on [dbo].[Products]
TO [Managers]  WITH GRANT OPTION
GRANT SELECT,INSERT, UPDATE, Delete
on [dbo].[Rooms]
TO [Managers]  WITH GRANT OPTION
GRANT SELECT,INSERT, UPDATE, Delete
on [dbo].[RoomsForTheCustomer]
TO [Managers]  WITH GRANT OPTION
GRANT SELECT,INSERT, UPDATE, Delete
on [dbo].[ShowRole]
TO [Managers]  WITH GRANT OPTION
GRANT SELECT,INSERT, UPDATE, Delete
on [dbo].[Tasks]
TO [Managers]  WITH GRANT OPTION
GRANT SELECT,INSERT, UPDATE, Delete
on [dbo].[TypeOfEmployes]
TO [Managers]  WITH GRANT OPTION
GRANT SELECT,INSERT, UPDATE, Delete
on [dbo].[TypesOfCustomers]
TO [Managers]  WITH GRANT OPTION

GRANT CREATE TABLE, CREATE PROCEDURE,CREATE VIEW
TO  Managers


grant select on [dbo].[Bill]
to [Customers]

grant SELECT,INSERT, UPDATE, Delete on [dbo].[Bill]
to [Receipts]
go