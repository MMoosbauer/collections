﻿<# ------Create Student Data from CSV file ------
How to use:
Rename the $filename to your needs. If necessary replace the Objects within the functions 
to firstname and lastname corresponding to cour .csv file. Change the @domain.de to your
corresponding domain.

The script will generate a .csv file when finished in the same folder. 
The name of the file is the current date.

Make sure your .csv file is in the same folder. As well as the shell. Prepare your.csv file.

!IMPORTANT!
If in your .csv file there is a row called "E-Mail", change it to Mail. PowerShell has does not recognize E-Mail
since its an built-in function. Editing .csv with EXCEL can lead to formating issues with vowls. Also, excel uses
a different limiter like ";", this will also lead to importing issues. The standard delmimiter should be an ",".

Modify the Objects to select from .csv file starting line 30.
#>
Clear-Host
# Filename
[string] $filename = "testdata.csv"

$date = Get-Date -Format yyyy-MM-dd-HH-mm-ss
# Set Date and Filename
$csvFileDB = $date + "-DB"
$csvFileAD = "import.csv"

#Initial CSV format
[string] $csvFormatDB = "fullname;username;firstname;lastname;ad;email;password"
[string] $csvFormatAD = "name;login;vorname;nachname;passwort;kurs"

#Append Format to file
$csvFormatDB >> .\"$csvFileDB.csv"
$csvFormatAD >> .\"$csvFileAD"

# Objects to select from .csv file | DO NOT USE "E-Mail" as Object it is an internal PowerShell function.
$delimiter = ";"
$firstname = "Vorname"
$lastname = "Nachname"
$domainName = "@domain.local"
$email = "Mail"
$course = "Kurs"

# Counter
$count = 0
$countAD = 0
$countDB = 0

# function to create student data 
function CreateStudentData {
    Import-Csv ".\$filename" -Delimiter $delimiter | Select-Object $firstname, $lastname, $email, $course | ForEach-Object {
        $count++
        # Vowl conversion
        function RemoveVowlsFromName {
            $_.$firstname = $_.$firstname.Replace("Ö", "Oe")
            $_.$firstname = $_.$firstname.Replace("Ä", "Ae")
            $_.$firstname = $_.$firstname.Replace("Ü", "Ue")
            $_.$firstname = $_.$firstname.Replace("ö", "oe")
            $_.$firstname = $_.$firstname.Replace("ä", "ae")
            $_.$firstname = $_.$firstname.Replace("ü", "ue")
            $_.$firstname = $_.$firstname.Replace("ß", "ss")
            $_.$firstname = $_.$firstname.Replace(" ", "-")
            $_.$lastname = $_.$lastname.Replace("Ö", "Oe")
            $_.$lastname = $_.$lastname.Replace("Ä", "Ae")
            $_.$lastname = $_.$lastname.Replace("Ü", "Ue")
            $_.$lastname = $_.$lastname.Replace("ö", "oe")
            $_.$lastname = $_.$lastname.Replace("ä", "ae")
            $_.$lastname = $_.$lastname.Replace("ü", "ue")
            $_.$lastname = $_.$lastname.Replace("ß", "ss")
            $_.$lastname = $_.$lastname.Replace(" ", "-")          
        }
        RemoveVowlsFromName;
        # Create Login and Mail from Substring
        $surname = $_.$lastname
        $name = $_.$firstname
        $privMail = $_.$email
        $courseID = $_.$course

        # Create User Data
        $fullName = $_.$firstname + " " + $_.$lastname 
        $login = $_.$firstname.Substring(0, 1) + "." + $_.$lastname
        $activDir = $_.$firstname.Substring(0, 1) + "." + $_.$lastname + $domainName
        
        # Random Numbers for Passwd
        $num1 = Get-Random -Minimum 10 -Maximum 100
        $num2 = Get-Random -Minimum 10 -Maximum 100

        # Roll indexes for character (re)placement
        $randIndexLower = Get-Random -Minimum 0 -Maximum 24
        $randIndexUpper = Get-Random -Minimum 0 -Maximum 24
        $randIndexLower2 = Get-Random -Minimum 0 -Maximum 24
        $randIndexUpper2 = Get-Random -Minimum 0 -Maximum 24

        # Roll characters exclude I and l
        $rplUpper = [char[]]([char]'A'..[char]'H' + [char]'J'..[char]'Z')
        $rplLower = [char[]]([char]'a'..[char]'k' + [char]'m'..[char]'z')

        # Piece Passwd together -> can be better with replace with random character
        $local:pass = $rplUpper[$randIndexUpper] + $rplLower[$randIndexLower] + $num1 + "#" + $rplUpper[$randIndexUpper2] + $rplLower[$randIndexLower2] + $num2 + "*"

        # Append to File as CSV     
        $fullName + ";" + $login.ToLower() + ";" + $name + ";" + $surname + ";" + $activDir + ";" + $privMail + ";" + $local:pass >> .\"$csvFileDB.csv"
        $fullName + ";" + $login.ToLower() + ";" + $name + ";" + $surname + ";" + $pass + ";" + $courseID >> .\"$csvFileAD"   
    }
    function GetCountInfo {
        # Count entires in created .csv files
        $tmpDB = Import-Csv ".\$csvFileDB.csv" | Select-Object $firstname | ForEach-Object { $countDB++ }
        # Status Message
        if ($countDB -eq $count ) {
            $outInfoDB = "OK!"
        }
        elseif ($countDB -lt $count) {
            $outInfoDB = "Not all files were transfered!`nCheck the syntax of the file or script."
        }
        $tmpAD = Import-Csv ".\$csvFileAD" | Select-Object $name | ForEach-Object { $countAD++ }

        if ($countAD -eq $count) {
            $outInfoAD = "OK!"
        }
        elseif ($countAD -lt $count) {
            $outInfoAD = "Not all files were transfered!`nCheck the syntax of the file or script." 
        }
        elseif ($countAD -gt $count) {
            $outInfoAD = "Check $csvFileAD for doubles!." 
        }
        # Summary
        Clear-Host
        Write-Host "Summary"
        Write-Host "----------------------------------------------------------------" -ForegroundColor Yellow
        Write-Host "DB CSV Status:" $outInfoDB
        Write-Host "AD CSV Status:" $outInfoAD
        Write-Host "`nDB CSV Entries created:" $countDB"/"$count -ForegroundColor Green
        Write-Host "AD CSV Entries created:" $countAD"/"$count -ForegroundColor Green
        Write-Host "`nSource filename:"$filename
        Write-Host "DB Output filename:"$csvFileDB".csv"
        Write-Host "AD Output filename:"$csvFileAD
        Write-Host "---------------------------------------------------------------`n" -ForegroundColor Yellow
    }
    GetCountInfo;
}
# Run function
CreateStudentData;