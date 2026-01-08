<#
sing code from the GetUser.ps1 file Create a function named GetUserData that:
Gets the users in the MyLabFiles.csv file and returns them as an object
#>
function Get-UserData {
    param (
        [string]$DatabaseFile = "$PSScriptRoot\git\NFAdvaniaLab2026\LabFiles\MyLabFile.csv"
    )
    
    $MyUserList = Get-Content -Path $DatabaseFile | ConvertFrom-Csv
    $MyUserList
}

<#
Using code from the GetUser.ps1 file Create a function named Get-CourseUser that:

Returns all users in the MyLabFiles.csv using the GetUserData helper function.
If a name is given, returns only that specific user
Change your function into an Advanced function
Add one more parameter to the function called OlderThan with a default value of 65
Make sure the OlderThan parameter accepts only int types as input
#>

function Get-CourseUser {
    [CmdletBinding()]
    param (
        [string]$Name,
        [int]$OlderThan = 65,
        [string]$DatabaseFile = "$PSScriptRoot\git\NFAdvaniaLab2026\LabFiles\MyLabFile.csv"
    )
    
    $MyUserList = GetUserData -DatabaseFile $DatabaseFile
    
    if ($PSBoundParameters.ContainsKey('Name')) {
        $MyUserList = $MyUserList | Where-Object -Property Name -Like "*$Name*"
    }
    
    if ($PSBoundParameters.ContainsKey('OlderThan')) {
        $MyUserList = $MyUserList | Where-Object -Property Age -GE $OlderThan
    }
    
    return $MyUserList
}

<#
Using code from the AddUser.ps1 file Create a function named Add-CourseUser that:

Has five parameters
DatabaseFile (Default value $PSScriptRoot\MyLabFile.csv)
Name (type [string], mandatory)
Age (type [int], mandatory)
Color (has a validateset 'red', 'green', 'blue', 'yellow', mandatory)
UserID (If none is given - generate one automatically)
Adds the given user to the database file
#>

function Add-CourseUser {

    param (
        [string]$DatabaseFile = "$PSScriptRoot\git\NFAdvaniaLab2026\LabFiles\MyLabFile.csv",
        [Parameter(Mandatory=$true)]
        [ValidatePattern("^[A-Z][\w\s-]*$", ErrorMessage="Name must start with a capital letter and contain only word characters, hyphens, and spaces.")]
        [string]$Name,
        [Parameter(Mandatory=$true)]
        [int]$Age,
        [Parameter(Mandatory=$true)]
        [ColorEnum]$Color,
        [int]$UserID
    )
    
    # Generate UserID if not provided
    if (-not $PSBoundParameters.ContainsKey('UserID')) {
        $UserID = Get-Random -Minimum 10 -Maximum 100000
    }
    
    # Create Participant instance and get CSV entry
    $User = [Participant]::new($Name, $Age, $Color, $UserID)
    $MyCsvUser = $User.ToString()
    
    # Read existing content and append new user
    $NewCSv = Get-Content $DatabaseFile -Raw
    $NewCSv += "$MyCsvUser"
    
    # Write back to file
    Set-Content -Value $NewCSv -Path $DatabaseFile
    
    Write-Output "User $Name added successfully with UserID: $UserID"
}

<#
 sing code from the GetUser.ps1 file Create a function named Remove-CourseUser that:

Has parameter DatabaseFile with a default value of $PSScriptRoot\MyLabFile.csv
Using SupportsShouldProcess and ConfirmImpact Asks the user for confirmation, and based on the answer
Deletes the user
Outputs "Did not remove user $($RemoveUser.Name)"
#>
function Remove-CourseUser {

    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
    param (
        [string]$DatabaseFile = "$PSScriptRoot\git\NFAdvaniaLab2026\LabFiles\MyLabFile.csv"
    )
    
    $RemoveUser = $MyUserList | Out-ConsoleGridView -OutputMode Single
    
    if ($null -eq $RemoveUser) {
        Write-Output "No user selected."
        return
    }
    
    if ($PSCmdlet.ShouldProcess("User: $($RemoveUser.Name)", "Remove")) {
        $MyUserList = $MyUserList | Where-Object {
            -not (
                $_.Name -eq $RemoveUser.Name -and
                $_.Age -eq $RemoveUser.Age -and
                $_.Color -eq $RemoveUser.Color -and
                $_.Id -eq $RemoveUser.Id
            )
        }
        Set-Content -Value $MyUserList -Path $DatabaseFile
        Write-Output "User $($RemoveUser.Name) removed successfully."
    }
    else {
        Write-Output "Did not remove user $($RemoveUser.Name)"
    }
}

<#
Validates all user IDs in the database to ensure they consist of numbers only.
Outputs any users with erroneous IDs.
#>
function Confirm-CourseID {
    [CmdletBinding()]
    param (
        [string]$DatabaseFile = "$PSScriptRoot\git\NFAdvaniaLab2026\LabFiles\MyLabFile.csv"
    )
    
    $UserList = Get-UserData -DatabaseFile $DatabaseFile
    $ErroneousUsers = @()
    
    foreach ($User in $UserList) {
        # Check if ID consists of numbers only
        if ($User.Id -notmatch '^\d+$') {
            $ErroneousUsers += $User
        }
    }
    
    if ($ErroneousUsers.Count -gt 0) {
        Write-Output "Found $($ErroneousUsers.Count) user(s) with erroneous ID(s):"
        $ErroneousUsers | Format-Table -AutoSize
    }
    else {
        Write-Output "All user IDs are valid (numbers only)."
    }
    
    return $ErroneousUsers
}

# Define ColorEnum
enum ColorEnum {
    red
    green
    blue
    yellow
}

# Define Participant class
class Participant {
    [string]$Name
    [int]$Age
    [ColorEnum]$Color
    [int]$Id

    # Constructor
    Participant([string]$Name, [int]$Age, [ColorEnum]$Color, [int]$Id) {
        $this.Name = $Name
        $this.Age = $Age
        $this.Color = $Color
        $this.Id = $Id
    }

    # ToString override to output as CSV
    [string]ToString() {
        return "$($this.Name),$($this.Age),$($this.Color),$($this.Id)"
    }
}

