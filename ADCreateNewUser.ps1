Clear-Host
<#--------------AD Create new users from .csv--------------
Hot to Use:
Edit the filename and OUs for groups and users to your corresponding ldap path. Change the 
$domainName and the variables corresponding to your .csv file. 

Make sure .csv is UTF-8 and not ANSI.
#>

# Filename
[string] $filename = "import.csv"

# User and Groups Organizazional Units | LDAP path
[string] $userOU = "OU=OU_Users,DC=moo,DC=zz"
[string] $groupOU = "OU=OU_Groups,DC=moo,DC=zz"

# Objects to select from .csv file | DO NOT USE "E-Mail" as variable for an Object it is an internal PowerShell function.
[string] $domainName = "@moo.zz"
[string] $delimiter = ";"
[string] $firstname = "vorname"
[string] $lastname = "nachname"
[string] $login = "login"
[string] $name = "name"
[string] $course = "kurs"
[string] $password = "passwort"

# Counter for metrics and debugging
[int32] $totalcount = 0
[int32] $groupCount = 0
[int32] $userCount = 0
# [int32] $userFailCount = 0
# [int32] $groupFailCount = 0

Write-Host "`n----------------------------WORKING----------------------------" -ForegroundColor Yellow
# Function for adding the users
function AddUserToAD {
    Import-Csv ".\$filename" -Delimiter $delimiter | Select-Object $firstname, $lastname, $login, $name, $course, $password | ForEach-Object {
        $totalcount++

        # Define Loop Variables
        $fname = $_.$firstname
        $lname = $_.$lastname
        $SAM = $_.$login
        $fullname = $_.$name
        $courseID = $_.$course
        $pass = $_.$password
        
        # Create UPN
        $UPN = $SAM + $domainName
       
        # Securing the Passwd 
        $securePass = $pass | ConvertTo-SecureString -AsPlainText -Force
    
        # Creating a new Group and ADUser | Catching User exists and Groups exists exceptions
        try {   
            New-ADGroup -Name "$courseID" -GroupCategory Security -GroupScope Global -SamAccountName "$courseID" -path "$groupOU" -DisplayName "$courseID"           
            $groupCount++
            Write-Host "Group: $courseID created."
        }
        catch {
            Write-Host "New-ADGroup : Gruppe: $courseID ist bereits vorhanden" -ForegroundColor Yellow
            # $groupFailCount++           
        }
        try {
            New-ADUser -Name "$fullname" -GivenName "$fname" -Surname "$lname" -SamAccountName "$SAM" -UserPrincipalName "$UPN" -Path "$userOU" -Description "$courseID" -AccountPassword($securePass) -Enabled $true -CannotChangePassword $true -PasswordNeverExpires $true <#-Server $serverName -ChangePasswordAtLogon $true#> 
            Add-ADPrincipalGroupMembership -Identity $SAM -MemberOf $courseID
            $userCount++
            Write-Host "Count[$totalcount] User: $fullname created."         
        }
        catch {
            Write-Host "New-ADUser : Konto: $fullname ist bereits vorhanden" -ForegroundColor Yellow        
            # $userFailCount++
        }      
        
        <# Debug output      
        Write-Host "Count[$totalcount]>--------------------------------------------------------->$UPN " -ForegroundColor Green
        Get-ADUser $SAM    
        Get-ADGroup $courseID
        #>     
    }
    # Summary 
    Write-Host "`n----------------------------SUMMARY----------------------------" -ForegroundColor Yellow
    Write-Host "`nUsers added: $userCount / $totalcount" -ForegroundColor Green   
    # Write-Host "Failed: $userFailCount" -ForegroundColor Red
    Write-Host "`nGroups added: $groupCount`n" -ForegroundColor Green 
    # Write-Host "Failed: $groupFailCount" -ForegroundColor Red
    Write-Host "---------------------------------------------------------------" -ForegroundColor Yellow
    Write-Host "REMOVE THE import.csv after use to avoid confusion." -ForegroundColor Red
    Write-Host "---------------------------------------------------------------" -ForegroundColor Yellow
}
AddUserToAD;