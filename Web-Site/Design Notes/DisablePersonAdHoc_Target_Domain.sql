USE [IAM]
GO

/****** Object:  StoredProcedure [dbo].[DisablePersonAdHoc_Accounts]    Script Date: 5/5/2023 3:40:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/*
		BY:			Ted Schuette
		Date:		20200325
		Purpose :	Remove Mapped Accounts for AssociateID passed in

*/
CREATE Procedure [dbo].[DisablePersonAdHoc_Accounts_Target_Domain]
	@TargetID NVARCHAR(20) = not null,
	@AssociateID NVARCHAR(20) = null,
	@EversanaID NVARCHAR (20) = null
	
AS
SET NOCOUNT ON;


	declare @sql nvarchar(100), @EVID nvarchar(20), @Trgt nvarchar(50), @usrnm nvarchar(50);

	IF(@AssociateID is not null and @EversanaID is null and @TargetID is not null)
	Begin 
		--print 'HERE1'
		declare c_TargetLoop cursor for
			Select I.eversanaID, I.targetid , I.Username
			from IdentityMap I
			INNER JOIN Profile P ON (P.EversanaID = I.EversanaID)
			inner join targets t on (t.TargetID = i.TargetID and t.Active = '1' and t.orphanremoval = '1')
			WHERE P.EMPLID = @AssociateID and I.TargetID = @TargetID
		open c_TargetLoop fetch next from c_TargetLoop into @EVID,@Trgt,@usrnm
		while @@FETCH_STATUS = 0
			Begin
				set @sql = 'exec '+@Trgt+'_RemoveUserAccountAdhoc '''','''+@usrnm+''''

					--print @sql
					EXECUTE (@sql)
				   Fetch NEXT from c_TargetLoop into @EVID,@Trgt,@usrnm
			end
		close c_TargetLoop
		deallocate c_TargetLoop;
	End
	IF(@AssociateID is null and @EversanaID is not null and @TargetID is not null)
	Begin 
		--print 'HERE2'
		declare c_TargetLoop cursor for
			Select I.eversanaID, I.targetid , I.Username
			from IdentityMap I
			inner join targets t on (t.TargetID = i.TargetID and t.Active = '1' and t.orphanremoval = '1')
			WHERE I.EversanaID = @EversanaID and I.TargetID = @TargetID
		open c_TargetLoop fetch next from c_TargetLoop into @EVID,@Trgt,@usrnm
		while @@FETCH_STATUS = 0
			Begin
				set @sql = 'exec '+@Trgt+'_RemoveUserAccountAdhoc '''','''+@usrnm+''''

					--print @sql
					EXECUTE (@sql)
				   Fetch NEXT from c_TargetLoop into @EVID,@Trgt,@usrnm
			end
		close c_TargetLoop
		deallocate c_TargetLoop;
	End
	IF(@AssociateID is not null and @EversanaID is not null and @TargetID is not null)
	Begin 
		--print 'HERE3'
		declare c_TargetLoop cursor for
			Select I.eversanaID, I.targetid , I.Username
			from IdentityMap I
			INNER JOIN Profile P ON (P.EversanaID = I.EversanaID)
			inner join targets t on (t.TargetID = i.TargetID and t.Active = '1' and t.orphanremoval = '1')
			WHERE P.EMPLID = @AssociateID and I.EversanaID = @EversanaID and I.TargetID = @TargetID
		open c_TargetLoop fetch next from c_TargetLoop into @EVID,@Trgt,@usrnm
		while @@FETCH_STATUS = 0
			Begin
				set @sql = 'exec '+@Trgt+'_RemoveUserAccountAdhoc '''','''+@usrnm+''''

					--print @sql
					EXECUTE (@sql)
				   Fetch NEXT from c_TargetLoop into @EVID,@Trgt,@usrnm
			end
		close c_TargetLoop
		deallocate c_TargetLoop;
	End

GO