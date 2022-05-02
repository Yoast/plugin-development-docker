# Switching to Rancher Desktop on MacOS

## Removing old entries

- Uninstall Docker Desktop
- Remove Existing Symlinks:

```bash
cd /usr/local/bin
rm docker kubectl docker-compose docker-compose-v1 docker-credential-desktop docker-credential-ecr-login docker-credential-osxkeychain com.docker.cli
cd ~
```

- In ~/.docker/config.json rename **credsStore** to **credStore**

## Installing Rancher Desktop

- Download [Rancher Desktop](https://rancherdesktop.io/)

- In the `General` tab disable: `Allow Collection of Anonymous statistics`
- In the `Kubernetes` tab change container runtime to: `dockerd (Moby)`
- In the `Kubernetes` uncheck the `enable kubernetes` box.
- In the `Kubernetes` tab change memory and CPU to half of your system resources.
- In the `Supporting Utilities` tab enable all symbolic links

If you can't create the symbolic links because you get an error that says:

> Insufficient permission to manipulate /usr/local/bin
This is probably because you're on an M1 Mac and this directory doesn't exist. To fix that:

```bash
sudo mkdir -p /usr/local/bin
sudo chown $USER /usr/local/bin
```

## Installing docker-compose

- Install docker-compose:

```bash
brew install docker-compose
```

## Setting up NFS

Run the following commands:

- `./clean.sh` && `./make.sh`

You can now start plugin-development-docker using `./start.sh`

## Troubleshooting

### Rancher not starting

- Rancher Desktop does not support macOS <10.15 please update to the latest macOS

### Stale NFS mount

macOs TCC polcies do not allow nfs mounting in the document folder.

- Move the repository files to ~/Projects/plugin-development-docker

### Macos Apache Keeps restarting
If you get "It Works!" in your browser while expecting to see a wordpress installation run the following command:

```bash
sudo launchctl unload -w /System/Library/LaunchDaemons/org.apache.httpd.plist
```
