# Set the credentials for the web site Azure accounts.
# Make sure you are logged in under the srv_IDMAppUI@eversana.com ID before you execute these commands.
# Open a powershell window under user srv_IDMAppUI

Next, copy and paste these following 4 lines into the PowerShell window.
This will reset the passwords with the correct encrypted credentials.

'tpn#%dioF3yZ'| ConvertTo-SecureString –AsPlainText –Force | ConvertFrom-SecureString|Out-File -FilePath c:\Apache24\credentials\EncryptedAzureAutomationPassword.txt
'vDB*xb#5wl8j'| ConvertTo-SecureString –AsPlainText –Force | ConvertFrom-SecureString|Out-File -FilePath c:\Apache24\credentials\EncryptedOneDriveRetentionPassword.txt
'm0DQTc@TeLTn'| ConvertTo-SecureString –AsPlainText –Force | ConvertFrom-SecureString|Out-File -FilePath c:\Apache24\credentials\EncryptedPowerBiPassword.txt
'&js66r(yyxpB(iRu6CG2'| ConvertTo-SecureString –AsPlainText –Force | ConvertFrom-SecureString|Out-File -FilePath c:\Apache24\credentials\IDMAPPPassword.txt
