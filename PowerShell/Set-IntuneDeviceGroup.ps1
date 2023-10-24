#Title: Classify Intune Managed Devices into Separate Groups
#Author: Gregory Warner
#Last Modified: 12/4/20

#For initial setup, install the necessary module on your computer
#Install-Module -Name Microsoft.Graph.Intune

#To get available commands for the module...
#Get-Command -Module Microsoft.Graph.Intune

#Connect to MSGraph first time with AdminConsent
# Connect-MSGraph -AdminConsent

Try
    {
        $credential = Get-AutomationPSCredential -Name 'a_Srv_IntuneReport'
        Connect-MSGraph -Credential $credential
        Connect-AzureAD -Credential $credential

        ### Step 1: Gather requisite data
        Write-Output "Step 1: Gather requisite data"
        # Get Culture for Proper Case
        $properCase = (Get-Culture).TextInfo

        # Get all managed devices from Endpoint Manager
        $managedDevices = Get-IntuneManagedDevice | Get-MSGraphAllPages

        # Get all devices in Azure AD for Object ID to add to group
        $devices = Get-AzureADDevice -all $true

        # Get all users in Azure AD
        $users = Get-AzureADUser -all $true

        ### Step 2: Provision needed groups if they do not exist
        Write-Output "Step 2: Provision needed groups if they do not exist"
        # Get unique business units
        $businessUnits = $users.extensionProperty.extension_906e14d00db8455cbcdd210acc93d584_division | Select-Object -Unique $_ | Where-Object {($_ -ne $null) -and ($_ -ne '')}

        # Get unique Field Solutions departments
        $FSDepartments = $($users | Where-Object {$_.extensionProperty.extension_906e14d00db8455cbcdd210acc93d584_division -eq "Field Solutions"}).Department | Select-Object -Unique $_ | Where-Object {($_ -ne $null) -and ($_ -ne '')}

        # Get unique locations
        $locations = $users.PhysicalDeliveryOfficeName | Select-Object -Unique $_ | Where-Object {($_ -ne $null) -and ($_ -ne '')}

        # Get unique operating systems
        $operatingSystems = $managedDevices.operatingSystem | Select-Object -Unique $_ | Where-Object {($_ -ne $null) -and ($_ -ne '')}

        # Get unique operating systems
        $managedDeviceOwnerTypes = $managedDevices.managedDeviceOwnerType | Select-Object -Unique $_ | Where-Object {($_ -ne $null) -and ($_ -ne '')}

        # Get all group GUIDs & Create Groups if Necessary
        $groups = @()
        foreach ($operatingSystem in $operatingSystems)
            {
                # Check for operating system group and create it if it doesn't exist
                $group = ''
                $group = "Intune-Devices-$operatingSystem-All"
                $groupAdd = ''
                $groupAdd = Get-AzureADGroup -Filter "DisplayName eq `'$group`'"
                if (($groupAdd -eq $null) -or ($groupAdd -eq ''))
                    {
                        $groups += New-AzureADGroup -DisplayName $group -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"
                    }
                else
                    {
                        $groups += $groupAdd
                    }
                # Check for managedDeviceOwnerType groups and create them if they don't exist
                foreach ($managedDeviceOwnerType in $managedDeviceOwnerTypes)
                    {
                        $managedDeviceOwnerTypeProper = ''
                        $managedDeviceOwnerTypeProper = $properCase.ToTitleCase($managedDeviceOwnerType)
                        $group = ''
                        $group = "Intune-Devices-$operatingSystem-OwnerType-$managedDeviceOwnerTypeProper"
                        $groupAdd = ''
                        $groupAdd = Get-AzureADGroup -Filter "DisplayName eq `'$group`'"
                        if (($groupAdd -eq $null) -or ($groupAdd -eq ''))
                            {
                                $groups += New-AzureADGroup -DisplayName $group -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"
                            }
                        else
                            {
                                $groups += $groupAdd
                            }
                    }
                # Check for business unit groups and create them if they don't exist
                foreach ($businessUnit in $businessUnits)
                    {
                        $group = ''
                        $group = "Intune-Devices-$operatingSystem-BU-$businessUnit"
                        $groupAdd = ''
                        $groupAdd = Get-AzureADGroup -Filter "DisplayName eq `'$group`'"
                        if (($groupAdd -eq $null) -or ($groupAdd -eq ''))
                            {
                                $groups += New-AzureADGroup -DisplayName $group -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"
                            }
                        else
                            {
                                $groups += $groupAdd
                            }
                    }
                # Check for location groups and create them if they don't exist
                foreach ($location in $locations)
                    {
                        $group = ''
                        $group = "Intune-Devices-$operatingSystem-Location-$location"
                        $groupAdd = ''
                        $groupAdd = Get-AzureADGroup -Filter "DisplayName eq `'$group`'"
                        if (($groupAdd -eq $null) -or ($groupAdd -eq ''))
                            {
                                $groups += New-AzureADGroup -DisplayName $group -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"
                            }
                        else
                            {
                                $groups += $groupAdd
                            }
                    }            
            }

        ### Step 3: Gather existing members of each group
        Write-Output "Step 3: Gather existing members of each group"
        foreach ($group in $groups)
            {
                $members = ''
                $members = Get-AzureADGroupMember -ObjectID $($group.ObjectId) -All $true

                New-Variable -Name $($group.DisplayName) -Value $members
            }
    }
Catch
    {
        #Email Parameters
        $smtpServer = 'smtp.office365.com'
        $smtpPort = 587
        $fromError = 'AzureAutomation@eversana.com'
        $smtpCredentialError = Get-AutomationPSCredential -Name 'Azure_Automation_Notification'
        $recipients = Get-AutomationVariable -Name "ErrorRecipientsIntune"
        [string[]]$toError = $recipients.Split(',')
        $subject = "Error Experienced Updating Intune Device Groups from Azure Automation"
        $body = `
@"
<table>
    <tbody>
        <tr>
            <td><img src="https://team.eversana.com/wp-content/uploads/2019/10/EmailHeader-IT-Service-Desk.png" width="545" height="85"></td>
        </tr>
        <tr>
            <td>
                <font face="arial">
                An error has been experienced updating Intune device groups, Set-IntuneDeviceGroups. Please investigate and respond accordingly.<br/>
                <br/>
                </font>
            </td>
        </tr>
    </tbody>
</table>
"@

        Send-MailMessage `
            -From $fromError `
            -To $toError `
            -Subject $subject `
            -Body $body `
            -BodyAsHtml `
            -UseSsl `
            -SmtpServer $smtpServer `
            -Port $smtpPort `
            -credential $smtpCredentialError
    }

        ### Step 4: Add each managedDevice to their proper groups
        Write-Output "Step 4: Add each managedDevice to their proper groups"
        foreach ($managedDevice in $managedDevices)
            {
                $UPN = ''
                $UPN = $managedDevice.userPrincipalName
                $user = ''
                $user = $users | Where-Object {$_.UserPrincipalName -eq $UPN}

                $managedDeviceOwnerTypeProper = ''
                $managedDeviceOwnerTypeProper = $properCase.ToTitleCase($($managedDevice.managedDeviceOwnerType))

                $groupRoot = ''
                $groupRoot = "Intune-Devices-$($managedDevice.operatingSystem)-"

                $groupTypes = @("All")
                if (($($user.extensionProperty.extension_906e14d00db8455cbcdd210acc93d584_division) -ne $null) -and ($($user.extensionProperty.extension_906e14d00db8455cbcdd210acc93d584_division) -ne ''))
                    {
                        $groupTypes += $("BU-$($user.extensionProperty.extension_906e14d00db8455cbcdd210acc93d584_division)")
                    }
                if (($($user.physicalDeliveryOfficeName) -ne $null) -and ($($user.physicalDeliveryOfficeName) -ne ''))
                    {
                        $groupTypes += $("Location-$($user.physicalDeliveryOfficeName)")
                    }
                if (($($managedDeviceOwnerTypeProper) -ne $null) -and ($($managedDeviceOwnerTypeProper) -ne ''))
                    {
                        $groupTypes += $("OwnerType-$managedDeviceOwnerTypeProper")
                    }

                $groupsAdd = @()
                foreach ($groupType in $groupTypes)
                    {
                        $groupAdd = ''
                        $groupAdd = $groups | Where-Object {$_.DisplayName -eq $($groupRoot + $groupType)}
                        if (($($groupAdd) -ne $null) -and ($($groupAdd) -ne ''))
                            {
                                $groupsAdd += $groupAdd
                            }
                    }

                if (($groupsAdd.count) -ne 0)
                    {
                        $deviceName = ''
                        $deviceName = $managedDevice.managedDeviceName

                        $deviceID = ''
                        $deviceID = $managedDevice.azureADDeviceId
                        $deviceObjectID = ''
                        $deviceObjectID = ($devices | Where-Object {$_.DeviceID -eq $deviceID}).ObjectId
                        if ($deviceObjectID -ne $null)
                            {
                                foreach ($groupAdd in $groupsAdd)
                                    {
                                        $membersCurrent = ''
                                        $membersCurrent = $(Get-Variable -name $($groupAdd.DisplayName) -ValueOnly).DeviceId
                                        if ($membersCurrent -notcontains $deviceID)
                                            {
                                                Write-Output "Adding $deviceName to $($groupAdd.DisplayName)"
                                                Add-AzureADGroupMember -ObjectId $($groupAdd.ObjectId) -RefObjectId $deviceObjectID
                                            }
                                    }
                            }
                    }
            }

        ### Step 5: Remove managedDevices from groups for which they no longer qualify
       Write-Output "Step 5: Remove managedDevices from groups for which they no longer qualify"
        foreach ($group in $groups)
            {
                Write-Output "Evaluating $($group.DisplayName)"
                $membersCurrent = ''
                $membersCurrent = $(Get-Variable -name $($group.DisplayName) -ValueOnly)

                # Break group name into an array
                $array = ''
                $array = $($($group.DisplayName).Split("-"))
                
                # Get group's type (e.g. BU, Location, OwnerType, etc.) 
                $conditionSwitch = ''
                $conditionSwitch = $array[3]

                # Get group's operating system (e.g. iOS, macOS, Windows, etc.)
                $conditionOS = ''
                $conditionOS = $array[2]

                # Get group's specific type (e.g. Shared Services, Patient Services, Milwaukee-WI-USA, etc.)
                $conditionType = ''
                Switch ($conditionSwitch)
                {
                    'All'
                        {
                            $conditionType = ''
                        }
                    'BU'
                        {
                            $conditionType = $($array[4])
                        }
                    'Location'
                        {
                            $conditionType = $($($array[4..$($array.length)]) -join "-")
                        }
                    'OwnerType'
                        {
                            $conditionType = $($array[4])
                        }
                }

                foreach ($memberCurrent in $membersCurrent)
                    {
                        $deviceID = ''
                        $deviceID = $memberCurrent.DeviceId
                        $managedDevice = ''
                        $managedDevice = $managedDevices | Where-Object {$_.azureADDeviceId -eq $deviceID}
                        if (($managedDevice -ne '') -and ($managedDevice -ne $null))
                            {
                                $UPN = ''
                                $UPN = $managedDevice.userPrincipalName
                                $user = ''
                                $user = $users | Where-Object {$_.UserPrincipalName -eq $UPN}
                        
                                $remove = ''
                                $remove = $false
                                Switch ($conditionSwitch)
                                    {
                                        'All'
                                            {
                                                if ($($managedDevice.operatingSystem) -ne $conditionOS)
                                                    {
                                                        $remove = $true
                                                    }
                                            }
                                        'BU'
                                            {
                                                if (($($managedDevice.operatingSystem) -ne $conditionOS) -or ($($user.extensionProperty.extension_906e14d00db8455cbcdd210acc93d584_division) -ne $conditionType))
                                                {
                                                    $remove = $true
                                                }
                                            }
                                        'Location'
                                            {
                                                if (($($managedDevice.operatingSystem) -ne $conditionOS) -or ($($user.physicalDeliveryOfficeName) -ne $conditionType))
                                                    {
                                                        $remove = $true
                                                    }
                                            }
                                        'OwnerType'
                                            {
                                                $managedDeviceOwnerTypeProper = ''
                                                $managedDeviceOwnerTypeProper = $properCase.ToTitleCase($($managedDevice.managedDeviceOwnerType))
                                                if (($($managedDevice.operatingSystem) -ne $conditionOS) -or ($managedDeviceOwnerTypeProper -ne $conditionType))
                                                    {
                                                        $remove = $true
                                                    }
                                            }
                                    }

                                if ($remove -eq $true)
                                    {
                                        Write-Output "Removing $($managedDevice.managedDeviceName) from $($group.DisplayName)"
                                        Remove-AzureADGroupMember -ObjectId $($group.ObjectId) -MemberId $($memberCurrent.ObjectId)
                                    }
                            }
                        else
                            {
                                Write-Output "No managedDevice found for $($memberCurrent.DisplayName)"
                            }
                    }
            }

        ### Step 6: Disconnect from Azure AD
        Write-Output "Step 6: Disconnect from Azure AD"
        Disconnect-AzureAD

