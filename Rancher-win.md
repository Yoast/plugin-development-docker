# Switching to Rancher Desktop on MacOS

## Removing old entries

- Uninstall Docker Desktop

## Installing Rancher Desktop

- Download [Rancher Desktop >= 1.0.1](https://github.com/rancher-sandbox/rancher-desktop/releases/download/v1.0.1/Rancher.Desktop.Setup.1.0.1.exe)

- In the `General` tab disable: `Allow Collection of Anonymous statistics`
- In the `Kubernetes` tab change container runtime to: `dockerd (Moby)` 
- In the `WSL Integration` tab check the checkbox next the `ubuntu` WSL.

## Installing Chocolatey

If you have previously installed Chocolatey you can skip this step

- Open Powershell with Administrative Priviledges
- Execute the following commands to install Chocolatey:

```powershell
Get-ExecutionPolicy
Set-ExecutionPolicy AllSigned
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

## Installing docker-compose

- Open Powershell with Administrative Priviledges
- Execute the following commands to install docker-compose:

```bash
choco install docker-compose
```

You can now use plugin-development-docker as you would normally would :)

## Troubleshooting
TBD
