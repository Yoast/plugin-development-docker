# Switching to Rancher Desktop on MacOS

## Removing old entries

- Uninstall Docker Desktop
- Remove Existing Symlinks:

```bash
cd /usr/local/bin
rm docker docker-compose-v1 docker-credential-desktop docker-credential-ecr-login docker-credential-osxkeychain com.docker.cli
cd ~
```

- In ~/.docker/config.json rename **credsStore** to **credStore**

## Installing Rancher Desktop

- Download [Rancher Desktop](https://github.com/rancher-sandbox/rancher-desktop/releases)
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
