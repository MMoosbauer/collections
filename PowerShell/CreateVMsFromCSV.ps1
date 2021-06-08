# Windows 7 "C:\_HDs-Main\win7\win7_sp1_ee_x86_en_DA-20170307.vhdx"
# Windows Server 2008 R2 "C:\_HDs-Main\w2k8r2\w2k8_r2_sp1_ee_x64_en_DA-20190815.vhdx"
# Windows Server 2012 R2 "C:\_HDs-Main\w2k12r2\w2k12_r2_en_20200204.vhdx"
# Windows 8.1 Enterprise "C:\_HDs-Main\win8.1\windows_8_1_enterprise_x64_en_20200403.vhdx"

$man_page = "
####################################################################
Create VM

Auto Mode
	Loads from .csv file in same directory. 
	Filename : .\test.csv
	The .csv file content should look like this:

EX	test.csv
	Name
	example.corp.contoso.com	

Manual Mode
	Lets you Create a VM with OS selection.

VMSettings
	2 NICS, 2 CPU, Differencing, Gen 1.
    vSwitch-MainOffice
    vSwitch-Internet
####################################################################"

function CheckExecutionPolicy{
Clear-Host;
$exec_policy = Read-Host "Check Execution Policy?(must be Admin!)`n[y]es | [n]o)"
if($exec_policy -eq "y"){
Clear-Host;
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force
};
if($exec_policy -eq "n"){
    Clear-Host;
};

};
function MenuMode {
Write-Host "$man_page";
Read-Host "Press any key to continue..."
Clear-Host;
Write-Host "Mode Selection"
$menu = Read-Host "`n[1] Auto | [2] Manual"
if($menu -eq 1){AutoCreateVMCSV};
if($menu -eq 2){OsSelector};
};

# Import from CSV
function AutoOsSelector{

[int32] $usr_selection = Read-Host "[1] win7 | [2] win2k12 r2 | [3] win8 | [4] win2k8 r2 | [5] Auto"

if($usr_selection -eq 1){
    $os_install = "C:\_HDs-Main\win7\win7_sp1_ee_x86_en_DA-20170307.vhdx"
    NewCreateVMCSV;
};
if($usr_selection -eq 2){
    $os_install = "C:\_HDs-Main\w2k12r2\w2k12_r2_en_20200204.vhdx"
    NewCreateVMCSV;
};
if($usr_selection -eq 3){
    $os_install = "C:\_HDs-Main\win8.1\windows_8_1_enterprise_x64_en_20200403.vhdx"
    NewCreateVMCSV;
};
if($usr_selection -eq 4){
    $os_install = "C:\_HDs-Main\w2k8r2\w2k8_r2_sp1_ee_x64_en_DA-20190815.vhdx"
    NewCreateVMCSV;
};
if($usr_selection -eq 5){
    Clear-Host;
};
};
function AutoCreateVMCSV {
Clear-Host;
$filename = Read-Host "`nEnter file name of .csv incl. extension"
Clear-Host;
Write-Host "OS Select for Auto Mode from .csv file"
[int32] $usr_selection = Read-Host "`n[1] win7 | [2] win2k12 r2 | [3] win8 | [4] win2k8 r2 | [5] Manual"
if($usr_selection -eq 1){
    $os_install = "C:\_HDs-Main\win7\win7_sp1_ee_x86_en_DA-20170307.vhdx"
};
if($usr_selection -eq 2){
    $os_install = "C:\_HDs-Main\w2k12r2\w2k12_r2_en_20200204.vhdx"
};
if($usr_selection -eq 3){
    $os_install = "C:\_HDs-Main\win8.1\windows_8_1_enterprise_x64_en_20200403.vhdx"
};
if($usr_selection -eq 4){
    $os_install = "C:\_HDs-Main\w2k8r2\w2k8_r2_sp1_ee_x64_en_DA-20190815.vhdx"
};
if($usr_selection -eq 5){
    Clear-Host;  
};
foreach ($row in(import-csv .\$filename)) {
    #$os_install = "C:\_HDs-Main\w2k8r2\w2k8_r2_sp1_ee_x64_en_DA-20190815.vhdx";
    $VMName = $row.Name 
    $VMPath =  "C:\_VMs\$VMName\Virtual Hard Disks\$VMName-hda.vhdx"
    new-vm -Name $VMName -NoVHD -Generation 1 -Path "C:\_VMs";
    set-vm -Name $VMName -DynamicMemory -MemoryMinimumBytes 512MB -ProcessorCount 2;
    Set-VMBios $VMName -EnableNumLock;
    New-VHD -Differencing -ParentPath $os_install -Path $VMPath;
    Add-VMHardDiskDrive -VMName $VMName -Path $VMPath -ControllerType IDE;
    Connect-VMNetworkAdapter -VMName $VMName -SwitchName "vSwitch-MainOffice";
    Add-VMNetworkAdapter -VMName $VMName -Name "Network Adapter" -SwitchName "vSwitch-Internet";
    Enable-VMIntegrationService -VMName $VMName -Name "Guest Service Interface";};
};

# Manual Mode
function CreateNewVM{
$VMName = Read-Host "Name of Virtual Machine"
$VMPath =  "C:\_VMs\$VMName\Virtual Hard Disks\$VMName-hda.vhdx"
new-vm -Name $VMName -NoVHD -Generation 1 -Path "C:\_VMs";
set-vm -Name $VMName -DynamicMemory -MemoryMinimumBytes 512MB -ProcessorCount 2;
Set-VMBios $VMName -EnableNumLock;
New-VHD -Differencing -ParentPath $os_install -Path $VMPath;
Add-VMHardDiskDrive -VMName $VMName -Path $VMPath -ControllerType IDE;
Connect-VMNetworkAdapter -VMName $VMName -SwitchName "vSwitch-MainOffice"
Add-VMNetworkAdapter -VMName $VMName -Name "Network Adapter" -SwitchName "vSwitch-Internet"
Enable-VMIntegrationService -VMName $VMName -Name "Guest Service Interface";
};
function OsSelector{
Clear-Host;
Write-Host "OS Select for Manual Mode from .csv file"
[int32] $usr_selection = Read-Host "[1] win7 | [2] win2k12 r2 | [3] win8 | [4] win2k8 r2 | [5] Exit"

if($usr_selection -eq 1){
    $os_install = "C:\_HDs-Main\win7\win7_sp1_ee_x86_en_DA-20170307.vhdx"
    CreateNewVM;
};
if($usr_selection -eq 2){
    $os_install = "C:\_HDs-Main\w2k12r2\w2k12_r2_en_20200204.vhdx"
    CreateNewVM;
};
if($usr_selection -eq 3){
    $os_install = "C:\_HDs-Main\win8.1\windows_8_1_enterprise_x64_en_20200403.vhdx"
    CreateNewVM;
};
if($usr_selection -eq 4){
    $os_install = "C:\_HDs-Main\w2k8r2\w2k8_r2_sp1_ee_x64_en_DA-20190815.vhdx"
    CreateNewVM;
};
if($usr_selection -eq 5){
    break;
};
};

# Functions
CheckExecutionPolicy;
MenuMode;
