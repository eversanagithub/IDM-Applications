-- Declare or variable @code which will hold the BU code from the 'hr_departments' table.
declare @code varchar(25)
-- Create a Cursor Object to store the result of the select statement. 
declare c_dataLoop cursor for select code from hr_departments where isActive = 'true' and level = '1'  
-- Open the Cursor opject so we can read from it.
open c_dataLoop 
-- Fetch each line within the Cursor object 'c_dataLoop'
fetch next from c_dataLoop into @code   
-- @@FETCH_STATUS is a built in function It will return the following status codes as it walks through each row:
--  0 = The Fetch Statement was successful 
-- -1 = The FETCH statement failed 
-- -2 = The FETCH row is misssing. 
-- -9 = The cursor is not performing a fetch operation.  
while @@FETCH_STATUS = 0
	begin
		select 'HIR',h.NBUDesc ,count(associateid) from hr_trx h where reason in ('HIR','REH') and IN_TBL_DATE > getdate()-1 and NBUDesc = @code group by h.NBUDesc
		select 'TER',h.NBUDesc ,count(associateid) from hr_trx h where reason in ('TER') and IN_TBL_DATE > getdate()-1 and NBUDesc = @code group by h.NBUDesc
-- The Fetch NEXT statement will store the results of the SQL statement in the variable '@code'.
    Fetch NEXT from c_dataLoop into @code
	end
close c_dataLoop
deallocate c_dataLoop;

declare @bu varchar(10)
declare myLoop cursor for select distinct HireBusCode from BusinessUnitByDay order by HireBusCode
open myLoop
fetch next from myLoop into @bu
while @@FETCH_STATUS = 0
begin
select HireDate,NBUDesc,numberhired from HiresStatistics where NBUDesc = @BU
Fetch next from myLoop into @bu
end
close myLoop
deallocate myLoop;
go

declare @bu varchar(10),@hireDate datetime,@NBUDesc varchar(20),@numberhired int,@totalCount int
declare myLoop cursor local fast_forward for select HireBusCode from BusinessUnitByDay order by HireBusCode
set @totalCount = 0
open myLoop
fetch next from myLoop into @bu
while @@FETCH_STATUS = 0
begin
select @hireDate = HireDate,@NBUDesc = NBUDesc,@numberhired = numberhired from HiresStatistics where NBUDesc = @BU
set @totalCount += @numberhired
Fetch next from myLoop into @bu
select @hireDate,@NBUDesc,@numberhired,@totalCount,@@FETCH_STATUS
end
close myLoop
deallocate myLoop;
go
-- ################################################################################
-- #    Procedure Name: DisplayFields                                             #
-- #      Date Written: March 6th, 2023                                           #
-- #        Written By: Dave Jaynes                                               #
-- #       Description: Record the individual fields within each SQL table into   #
-- #                    the 'TableDescriptions' SQL table for reference purposes. #
-- ################################################################################

ALTER PROCEDURE [dbo].[DisplayFields] as

-- Declare all our table variable names.
declare @TableName varchar(30),@Column_Name varchar(30),@DATA_TYPE varchar(20),@CHARACTER_MAXIMUM_LENGTH int,@NewTable varchar(20),@SQL VARCHAR(MAX)

-- This is the name of the table that will be created.
set @NewTable = 'TableDescriptions'

-- Nuke the 'TableDescriptions' table if it exists so we can start with a fresh copy.
SET @SQL = 'IF EXISTS(SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N''' + @NewTable + ''') AND type = (N''U'')) DROP TABLE [' + @NewTable + ']'
EXEC (@SQL);

-- Now recreate the 'TableDescriptions' table.
set @SQL = 'CREATE TABLE dbo.' + quotename(@NewTable, '[') + '(TableName varchar(30) null,Column_Name varchar(30),DATA_TYPE varchar(20),CHARACTER_MAXIMUM_LENGTH int);';
EXEC (@SQL)

-- Declare our outer loop cursor which will supply us with the table names.
declare TableName cursor fast_forward for SELECT DISTINCT TABLE_NAME FROM INFORMATION_SCHEMA.COLUMNS
open TableName
fetch next from TableName into @TableName
while @@FETCH_STATUS = 0
begin 

	-- Declare our inner loop cursor which will pull the table column details.
	declare TableColumns cursor local fast_forward for select COLUMN_NAME,DATA_TYPE,CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @TableName
	open TableColumns
	fetch next from TableColumns into @Column_Name,@DATA_TYPE,@CHARACTER_MAXIMUM_LENGTH
	while @@FETCH_STATUS = 0
	begin
	
		-- Insert the table column data into the 'TableDescriptions' table and fetch the next row.
		insert into TableDescriptions(TableName,COLUMN_NAME,DATA_TYPE,CHARACTER_MAXIMUM_LENGTH) values (@TableName,@Column_Name,@DATA_TYPE,@CHARACTER_MAXIMUM_LENGTH)
		fetch next from TableColumns into @Column_Name,@DATA_TYPE,@CHARACTER_MAXIMUM_LENGTH
	end
	
	-- Close out the outer loop.
	close TableColumns
	deallocate TableColumns
	fetch next from TableName into @TableName
end

-- Close out the inner loop.
close TableName
deallocate TableName
go



