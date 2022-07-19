# install wsl2 

- run `wsl --install`

## Installing Rancher Desktop

- Download [Rancher Desktop >= 1.4.1](https://rancherdesktop.io/)

- In the `General` tab disable: `Allow Collection of Anonymous statistics`
- In the `Kubernetes` tab change container runtime to: `dockerd (Moby)`
- In the `Kubernetes` uncheck the `enable kubernetes` box
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

## Troubleshooting
TBD
