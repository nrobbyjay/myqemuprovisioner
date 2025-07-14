Function Select-ROM
{
    Write-Host "Select Installer ISO"
    Add-Type -AssemblyName System.Windows.Forms
    $ROM = New-Object System.Windows.Forms.OpenFileDialog
        $Show = $ROM.ShowDialog()
        If ($Show -eq "OK")
        {
            Return $ROM.FileName
        }
        Else
        {
            Write-Error "Operation cancelled by user."
        }
}

Function Select-Image
{
    Write-Host "Select Installer ISO"
    Add-Type -AssemblyName System.Windows.Forms
    $ROM = New-Object System.Windows.Forms.OpenFileDialog
        $Show = $ROM.ShowDialog()
        If ($Show -eq "OK")
        {
            Return $ROM.FileName
        }
        Else
        {
            Write-Error "Operation cancelled by user."
        }
}


Function Select-Cloud
{
    Write-Host "Select Cloud Image"
    Add-Type -AssemblyName System.Windows.Forms
    $ROM = New-Object System.Windows.Forms.OpenFileDialog
        $Show = $ROM.ShowDialog()
        If ($Show -eq "OK")
        {
            Return $ROM.FileName
        }
        Else
        {
            Write-Error "Operation cancelled by user."
        }    
}

Function Create-CloudInit
{
    do{
        $CreateCloudDisk = Read-Host "Use clouddisk? y/n"
        if($CreateCloudDisk -eq "y"){
            Write-Host "Select UserData"
            Add-Type -AssemblyName System.Windows.Forms
            $UserDataForm = New-Object System.Windows.Forms.OpenFileDialog
            $ShowDialogUserData = $UserDataForm.ShowDialog()
            If ($ShowDialogUserData -eq "OK")
            {
                $UserData=$UserDataForm.FileName
            }
            Else
            {
                Write-Error "Operation cancelled by user."
            }
            Write-Host "Select MetaData"
            $MetaDataForm = New-Object System.Windows.Forms.OpenFileDialog
            $ShowMetaDataForm = $MetaDataForm.ShowDialog()
            If ($ShowMetaDataForm -eq "OK")
            {
                $MetaData=$MetaDataForm.FileName
            }
            Else
            {
                Write-Error "Operation cancelled by user."
            }
            New-VHD "cloudinit.vhd" -SizeBytes 260MB -Fixed
            Mount-VHD -Path "cloudinit.vhd"
            $DISKNUMBER = (Get-Disk | Where-Object {$_.Size -eq "260MB" -and $_.PartitionStyle -eq "RAW"}).Number
@"
select disk $DISKNUMBER
clean
create partition primary
format fs=fat32 label=cidata quick
assign letter=Z
exit
"@ | diskpart
            #Sanitize File - future
            Copy-Item -Path $UserData -Destination "Z:\" -Force
            Copy-Item -Path $MetaData -Destination "Z:\" -Force
            Dismount-VHD -Path cloudinit.vhd
            Return "cloudinit.vhd"
        }
        elseif($CreateCloudDisk -eq "n"){
            Return $null
        }
        else
        {
            Write-Host "Invalid Selection, try again"
            $CreateCloudDisk = $null
        }
    
    }
    while($CreateCloudDisk -ne "y" -and $CreateCloudDisk -ne "no" -and $CreateCloudDisk -eq $null)

}

Function Provision-Cloud
{
    param([string]$ImagePATH, [string]$CLOUDINITPATH, [string]$NETWORK)
    if($NETWORK -eq "y" -and $CLOUDINITPATH -ne $null){
    $NetDev="tap,id=net0,ifname=tap0,script=no,downscript=no"
    $DeviceNet="e1000,netdev=net0"
    Start-Process qemu-system-x86_64 -ArgumentList @(
        "-cpu", "qemu64"
        "-m", "1024"
        "-cdrom", "file=cloudinit.vhd,format=raw,media=cdrom,readonly=on"
        "-smp", 2
        "-accel", "whpx"
        "-drive", "file=$ImagePATH"
        "-boot", "d"
        "-netdev", $NetDev
        "-device", $DeviceNet
        "-display", "sdl"
    )
    }
    if($NETWORK -eq "n" -and $CLOUDINITPATH -eq $null){
    Start-Process qemu-system-x86_64 -ArgumentList @(
        "-cpu", "qemu64"
        "-m", "1024"
        "-smp", 2
        "-accel", "whpx"
        "-drive", "file=$ImagePATH"
        "-boot", "d"
        "-display", "sdl"
    )
    }

    if($NETWORK -eq "y" -and $CLOUDINITPATH -ne $null){
    $NetDev="tap,id=net0,ifname=tap0,script=no,downscript=no"
    $DeviceNet="e1000,netdev=net0"
    Start-Process qemu-system-x86_64 -ArgumentList @(
        "-cpu", "qemu64"
        "-m", "1024"
        "-smp", 2
        "-accel", "whpx"
        "-drive", "file=$ImagePATH"
        "-boot", "d"
        "-netdev", $NetDev
        "-device", $DeviceNet
        "-display", "sdl"
    )
    }
}

Function Provision2
{
    param([string]$CDROMPATH, [string]$CLOUDINITPATH, [string]$NETWORK)
    qemu-img create hdd.qcow2 32G -f qcow2
    if($NETWORK -eq "y" -and $CLOUDINITPATH -ne $null){
    $NetDev="tap,id=net0,ifname=tap0,script=no,downscript=no"
    $DeviceNet="e1000,netdev=net0"
    Start-Process qemu-system-x86_64 -ArgumentList @(
        "-cpu", "qemu64"
        "-m", "1024"
        "-cdrom", $CDROMPATH
        "-cdrom", "file=cloudinit.vhd,format=raw,media=cdrom,readonly=on"
        "-smp", 2
        "-accel", "whpx"
        "-drive", "file=hdd.qcow2"
        "-boot", "d"
        "-netdev", $NetDev
        "-device", $DeviceNet
        "-display", "sdl"
    )
    }
    if($NETWORK -eq "n" -and $CLOUDINITPATH -eq $null){
    Start-Process qemu-system-x86_64 -ArgumentList @(
        "-cpu", "qemu64"
        "-m", "1024"
        "-cdrom", $CDROMPATH
        "-smp", 2
        "-accel", "whpx"
        "-drive", "file=hdd.qcow2"
        "-boot", "d"
        "-display", "sdl"
    )
    }

    if($NETWORK -eq "y" -and $CLOUDINITPATH -ne $null){
    $NetDev="tap,id=net0,ifname=tap0,script=no,downscript=no"
    $DeviceNet="e1000,netdev=net0"
    Start-Process qemu-system-x86_64 -ArgumentList @(
        "-cpu", "qemu64"
        "-m", "1024"
        "-cdrom", $CDROMPATH
        "-smp", 2
        "-accel", "whpx"
        "-drive", "file=hdd.qcow2"
        "-boot", "d"
        "-netdev", $NetDev
        "-device", $DeviceNet
        "-display", "sdl"
    )
    }
}


Function GenerateLaunchScript
{
@"
qemu-system-x86_64.exe -cpu qemu64 -m 1024 -smp 2 -accel whpx -drive file=hdd.qcow2,format=qcow2 -boot d -netdev tap,id=net0,ifname=tap0,script=no,downscript=no -device e1000,netdev=net0 -display sdl
"@ | Out-File "launch_sdl.ps1" 

@"
qemu-system-x86_64.exe -cpu qemu64 -m 1024 -smp 2 -accel whpx -drive file=hdd.qcow2,format=qcow2 -boot d -netdev tap,id=net0,ifname=tap0,script=no,downscript=no -device e1000,netdev=net0 -display none
"@ | Out-File "launch.ps1" 

}

Function init
{
    Write-Host "Visit github.com/nrobbyjay/myqemuprovisioner for usage guidance"
    $UseCloudImage = Read-Host "Deploy Cloud Image? y/n"
    if($UseCloudImage -eq "y"){
        $CloudImage = Select-Image
        $EnableNetwork=Read-Host "Enable network? y/n"
        Provision-Cloud -ImagePATH $CloudImage -CLOUDINITPATH $CLOUDINIT -NETWORK $EnableNetwork
        GenerateLaunchScript
    }
    elseif($UseCloudImage -eq "n"){
        $CDROM=Select-ROM
        $CLOUDINIT = Create-CloudInit
        $EnableNetwork=Read-Host "Enable network? y/n"
        Provision2 -CDROMPATH $CDROM -CLOUDINITPATH $CLOUDINIT -NETWORK $EnableNetwork
        GenerateLaunchScript
    }
    else{
        Write-Host "Incorrect Selection, repeating..."
        init
    }


}

init
