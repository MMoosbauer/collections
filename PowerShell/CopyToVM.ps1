
<# Copies files from Host to VM
Change the path to the file it is set to C:\ by default
on Source and Destination.
#>

function CpToVM {
    # Variables
    $VM = Read-Host "Target VM"
    $filename = Read-Host "File to copy (including extension)"

    # Commandlet
    Copy-VMFile "$VM" -SourcePath "C:\$filename" -DestinationPath "C:\$filename" -CreateFullPath -FileSource Host
}

CpToVM;