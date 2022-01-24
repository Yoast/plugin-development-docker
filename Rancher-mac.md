# Switching to Rancher Desktop on MacOS

## Removing old entries

- Uninstall Docker Desktop
- Remove Existing Symlinks:

```bash
cd /usr/local/bin
rm docker docker-compose docker-compose-v1 docker-credential-desktop docker-credential-ecr-login docker-credential-osxkeychain com.docker.cli
cd ~
```

- In ~/.docker/config.json rename **credsStore** to **credStore**

## Installing Rancher Desktop

- Download Rancher Desktop
  - Rancher Desktop is still in beta at the moment of writing, to make sure that you are on the same version please use the following links to download:
    - [macOS Intel (Most Common)](https://github.com/rancher-sandbox/rancher-desktop/releases/download/v1.0.0-beta.1/Rancher.Desktop-1.0.0-beta.1.x86_64.dmg)
    - [macOS M1](https://github.com/rancher-sandbox/rancher-desktop/releases/download/v1.0.0-beta.1/Rancher.Desktop-1.0.0-beta.1.aarch64.dmg)
    - [Windows](https://github.com/rancher-sandbox/rancher-desktop/releases/download/v1.0.0-beta.1/Rancher.Desktop.Setup.1.0.0-beta.1.exe)

- In the `General` tab disable: `Allow Collection of Anonymous statistics`
- In the `Kubernetes` tab change container runtime to: `dockerd (Moby)` 
- In the `Kubernetes` tab change memory and CPU to half of your system resources.
- In the `Supporting Utilities` tab enable all symbolic links

## Installing docker-compose

- Install docker-compose:

```bash
brew install docker-compose
```

You can now use plugin-development-docker as you would normally would :)
