# Adapted from https://gist.github.com/daehahn/497fa04c0156b1a762c70ff3f9f7edae?WT.mc_id=-blog-scottha

# WSL2 network port forwarding script v1
#   for enable script, 'Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser' in Powershell,
#   for delete exist rules and ports use 'delete' as parameter, for show ports use 'list' as parameter.
#   written by Daehyuk Ahn, Aug-1-2020

# Display all portproxy information
If ($Args[0] -eq "list") {
    netsh interface portproxy show v4tov4;
    exit;
} 

# If elevation needed, start new process
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
  # Relaunch as an elevated process:
  Start-Process powershell.exe "-File",('"{0}"' -f $MyInvocation.MyCommand.Path),"$Args runas" -Verb RunAs
  exit
}

# You should modify '$Ports' for your applications 
$Ports = (80,443,2222,8080)

# Check WSL ip address
wsl.exe zsh -c "ip addr show eth0 | rg 'inet\s' | cut -f1 -d '/' | sed -re 's/.*inet\s(.*)/\1/'" | Set-Variable -Name "WSL"
$found = $WSL -match '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}';
if (-not $found) {
  echo "WSL2 cannot be found. Terminate script.";
  exit;
}

# Remove and Create NetFireWallRule
Remove-NetFireWallRule -DisplayName 'wsl2_port_forward';
if ($Args[0] -ne "delete") {
  New-NetFireWallRule -DisplayName 'wsl2_port_forward' -Direction Outbound -LocalPort $Ports -Action Allow -Protocol TCP;
  New-NetFireWallRule -DisplayName 'wsl2_port_forward' -Direction Inbound -LocalPort $Ports -Action Allow -Protocol TCP;
}

# Add each port into portproxy
$Addr = "0.0.0.0"
Foreach ($Port in $Ports) {
    iex "netsh interface portproxy delete v4tov4 listenaddress=$Addr listenport=$Port | Out-Null";
    if ($Args[0] -ne "delete") {
        iex "netsh interface portproxy add v4tov4 listenaddress=$Addr listenport=$Port connectaddress=$WSL connectport=$Port | Out-Null";
    }
}

# Display all portproxy information
netsh interface portproxy show v4tov4;

# Give user to chance to see above list when relaunched start
If ($Args[0] -eq "runas" -Or $Args[1] -eq "runas") {
  Write-Host -NoNewLine 'Press any key to close! ';
  $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}
