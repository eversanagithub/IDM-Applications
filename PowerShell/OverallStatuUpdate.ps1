#Load SharePoint CSOM Assemblies 
Add-Type -Path "C:\PowerShell\ITPMO\Microsoft.SharePoint.Client.dll" 
Add-Type -Path "C:\PowerShell\ITPMO\Microsoft.SharePoint.Client.Runtime.dll" 
#Variables 
$SiteURL="https://eversana.sharepoint.com/sites/ITPMO" 
$ListName="Intake" 
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Try 
{ 
    #Set user name and password to connect
    $UserName="pmopowerbi@eversana.com"
    $Password = '$fPXGnI5vwC3'
 
    #Create Credential object from given user name and password
    $Cred = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName,(ConvertTo-SecureString $Password -AsPlainText -Force))
    
    #Set up the context
    $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteUrl)
    $Ctx.Credentials = $Cred

     #$Cred= Get-Credential 
     #$Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)
     #Setup the context 
     #$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL) 
     #$Ctx.Credentials = $Credentials 
     $Web = $Ctx.web 
 
     #Get the List 
     $List = $Ctx.Web.Lists.GetByTitle($ListName) 
     $Ctx.Load($List) 
     $Ctx.ExecuteQuery() 
     #Get All List items 
     $ListItemsCAML = New-Object Microsoft.SharePoint.Client.CamlQuery 
     $ListItemsCAML.ViewXml = "<View Scope='RecursiveAll'></View>" 
     $ListItems = $List.GetItems($ListItemsCAML) 
     $Ctx.Load($ListItems) 
     $Ctx.ExecuteQuery() 
     Write-host "Total Items Found:"$List.ItemCount 

     #Iterate through each item and update 
     Foreach ($ListItem in $ListItems) 
     { 
         #Set New value for List column 
         $ListItem["Overall_Previous"] = $ListItem["Overall"] 
         $ListItem["Editor"] = $ListItem["Editor"] 
         $ListItem["Modified"] = $ListItem["Modified"] 
         
         $ListItem.SystemUpdate() 

         $Ctx.ExecuteQuery() 
         Write-host "Item : Title - "$ListItem["Title"] "& ID: " $ListItem["ID"] "Updated Successfully!" -ForegroundColor Green
     } 
    Write-host "All Items in the List: $ListName Updated Successfully!" -ForegroundColor Green 
 } 
 Catch 
 { 
    write-host -f Red "Error Updating List Items!" $_.Exception.Message 
 }