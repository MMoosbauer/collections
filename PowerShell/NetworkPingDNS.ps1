Clear-Host;
[bool] $running;
[string] $custom_name = "probe.log";
# [string] $custom_name = Read-Host "Enter your cutom File Name including file extension";
New-Item -Path . -Name "$custom_name" -ItemType File -Force;
Clear-Host; 
function GetHostInfo {
    Get-NetRoute | Select-Object NextHop, DestinationPrefix, RouteMetric, ifIndex | Sort-Object DestinationPrefix >> ".\$custom_name";
    Get-NetAdapter | Select-Object Name,MacAddress,ifIndex | Sort-Object Name >> ".\$custom_name";
    Get-NetNeighbor | select-object ifIndex,LinkLayerAddress,State,IPAddress | sort-object IPAddress >> ".\$custom_name";
    Get-NetIPConfiguration -Detailed >> ".\$custom_name";
    Get-ComputerInfo | Select-Object CsName,CsUserName,CsDomain,CsDomainRole,CsStatus,OsUptime,OsLastBootUpTime,OsLocalDateTime >> ".\$custom_name";
}
function CombinedExit {
    [string] $filename = Read-Host "Enter the filename with extension to Import (same directory)`n>";  
    [string] $response = Read-Host "`nResponse Time Measurement? [Y] | [N]`n>";     
    [int32] $ping_count = Read-Host "`nPings per Entry?`n>";
    [string] $type = "Name"; # Read-Host "Type: Data = IPv4/IPv6 | Name = DNS Host A";  
    Clear-Host;
    Import-Csv ".\$filename" | Select-Object Name,Data | ForEach-Object {
        $(Write-Host "Running ... Please wait")
        $(Get-Date >> ".\$custom_name";)
        $(Write-Host $_.Name)
        $(Write-Host $_.Data)
        $(Test-Connection -Count $ping_count $_.$type >> ".\$custom_name")
        $(Test-Connection -Count $ping_count $_.$type >> ".\$custom_name")
        if ($response -eq "y") {
            Test-Connection -Count $ping_count $_.$type | Measure-Object -Property ResponseTime -Average -Sum -Maximum -Minimum -Verbose >> ".\$custom_name"     
        };
        $(Resolve-DnsName -Name $_.Name >> ".\$custom_name")
        $(Resolve-DnsName -Name $_.Name -Type SOA >> ".\$custom_name")   
        $(Clear-Host)
        };
    Get-NetIPConfiguration >> ".\$custom_name";
}
function ResolveNames {
    [string] $filename = Read-Host "Enter the filename with extension to Import (same directory)";
    Clear-Host;
    Import-Csv ".\$filename" | Select-Object Name,Data | ForEach-Object {
        Write-Host "Running ... Please wait";
        Get-Date >> ".\$custom_name";
        Write-Host $_.Name;
        Write-Host $_.Data;
        Resolve-DnsName -Name $_.Name >> ".\$custom_name";
        Resolve-DnsName -Name $_.Name -Type SOA >> ".\$custom_name";
        Clear-Host;
        };  
}
function PingCSVData {
    [string] $filename = Read-Host "Enter the filename with extension to Import (same directory)";  
    [string] $response = Read-Host "`nResponse Time Measurement? [Y] | [N]";     
    [int32] $ping_count = Read-Host "`nPings per Entry?";
    [string] $type = "Name"; # Read-Host "Type: Data = IPv4/IPv6 | Name = DNS Host A";  
    Clear-Host;
    Import-Csv ".\$filename" | Select-Object Name,Data | ForEach-Object {
        Write-Host "Pinging:" $_.Name;
        Write-Host "`nIP: " $_.Data;
        Get-Date >> ".\$custom_name";
        Test-Connection -Count $ping_count $_.$type >> ".\$custom_name";
        if ($response -eq "y") {
            Write-Host "`nMeasuring Response Time"
            Test-Connection -Count $ping_count $_.$type | Measure-Object -Property ResponseTime -Average -Sum -Maximum -Minimum -Verbose >> ".\$custom_name"          
        };   
        Clear-Host;
        };
    Get-NetIPConfiguration >> ".\$custom_name";      
}
function ModeSelection {
Write-Host "Main Menu`n"
$mode_select = Read-Host "(1) Host Info`n(2) Resolve Names`n(3) Ping Only`n(4) Combined & Exit`n(5) Display Content`n(6) Help`n(7) Exit`n>";
Clear-Host;
switch($mode_select)
{
    "1"{GetHostInfo; Get-Content ".\$custom_name"; ModeSelection;} 
    "2"{ResolveNames; Get-Content ".\$custom_name"; ModeSelection;}
    "3"{PingCSVData; Get-Content ".\$custom_name"; ModeSelection;}
    "4"{CombinedExit; GetHostInfo; Get-Content ".\$custom_name"; break;}
    "5"{Clear-Host; Get-Content ".\$custom_name";}
    "6"{[string]$man_page = "
        ##############################################################
        Probe Manual
        
        Imports a .csv file. The .csv file should look like:
        The file must be placed in the SAME directory as the script.
        
        Filename: example.csv
        
        Content of file example.csv: 
        
        Name,Data
        localhost,127.0.0.1
        
        Probe will generate a probe.log. This will generate each time 
        Probe.ps1 is run. 
        ##############################################################
        " 
            Write-Host $man_page;
            Read-Host "`nPress any key to go back ..." ;
            Clear-Host;
            ModeSelection;
    }
    "7"{break;}
    default{"Invalid Input"; break;}
};
}
ModeSelection;
