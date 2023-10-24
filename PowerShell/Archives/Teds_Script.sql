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
declare myLoop cursor for select HireBusCode from BusinessUnitByDay order by HireBusCode
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

Alter PROCEDURE [dbo].[DisplayHires] as
declare @bu varchar(10),@hireDate datetime,@NBUDesc varchar(20),@OldNBUDesc varchar(20),@numberhired int,@totalCount int,@DTG datetime
declare DTGLoop cursor for select DTG from StaffingDates
set @OldNBUDesc = ''
open DTGLoop
fetch next from DTGLoop into @DTG
while @@FETCH_STATUS = 0
begin 
	declare BULoop cursor for select distinct HireBusCode from BusinessUnitByDay order by HireBusCode
	set @totalCount = 0
	open BULoop
	fetch next from BULoop into @bu
	while @@FETCH_STATUS = 0
	begin
		select @hireDate = HireDate,@NBUDesc = NBUDesc,@numberhired = numberhired from HiresStatistics where NBUDesc = @BU and HireDate = @DTG
		if @NBUDesc != @OldNBUDesc
		begin
			select @DTG,@hireDate,@OldNBUDesc,@numberhired,@totalCount
			set @OldNBUDesc = @NBUDesc
			set @totalCount = 0
		end
		set @totalCount += @numberhired
		fetch next from BULoop into @bu
	end
	close BULoop
	deallocate BULoop;
	fetch next from DTGLoop into @DTG
end
close DTGLoop
deallocate DTGLoop
go
exec DisplayHires;
go


