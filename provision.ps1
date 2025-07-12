Function Select-ROM
{
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

Function Provision
{
    param([string]$CDROMPATH)
    qemu-img create hdd.qcow2 32G -f qcow2
    qemu-system-x86_64.exe -cpu qemu64 -m 1024 -cdrom $CDROMPATH -smp 2 -accel whpx -drive file=hdd.qcow2,format=qcow2 -boot d -netdev tap,id=net0,ifname=tap0,script=no,downscript=no -device e1000,netdev=net0 -display sdl
}

Function GenerateLaunchScript
{
@"
qemu-system-x86_64.exe -cpu qemu64 -m 1024 -smp 2 -accel whpx -drive hdd.qcow2 -boot d -netdev tap,id=net0,ifname=tap0,script=no,downscript=no -device e1000,netdev=net0 display sdl
"@ | Out-File "launch_sdl.ps1" 

@"
qemu-system-x86_64.exe -cpu qemu64 -m 1024 -smp 2 -accel whpx -drive hdd.qcow2 -boot d -netdev tap,id=net0,ifname=tap0,script=no,downscript=no -device e1000,netdev=net0 display none
"@ | Out-File "launch.ps1" 

}

Function init
{
    $CDROM=Select-ROM
    Provision -CDROMPATH $CDROM
    GenerateLaunchScript

}

init