# WordPress Plugin Development Docker

This is a fairly simple docker container to facilitate development of WordPress plugins.

## Prerequisites

Mac users:

- [Rancher Desktop](https://rancherdesktop.io/) see the [Rancher-mac.md](./Rancher-mac.md) guide on how to switch.

Windows WSL2:
Running this setup from WSL is the preferd way. 

- [Rancher Desktop](https://rancherdesktop.io/) see the [Rancher-win.md](./Rancher-win.md) guide on how to switch.
- [GitExtensions](https://github.com/gitextensions/gitextensions/releases/) includes some unix tools we need.
- optional [GSudo](https://github.com/gerardog/gsudo) allows shell scripts to use sudo command on windows

Windows install:

- Friendly dns names (e.g. basic.wordpress.test) will not work out of the box
  possible fix: make the `c:\windows\system32\drivers\etc\hosts` write and change for users, before running ./setup.sh script from WSL after running the .setup.sh this can be removed again
- Ssl trust will not work out of the box add the config/certs/wordpress.text.crt to the trusted list in windows it self(NOT WSL)
  - First copy the cert to the Windows file system. `cp config/certs/wordpress.test.crt /mnt/c/Users/WindowsUserName/Desktop`
  - Then add the ssl cert to the Windows certificate store. Start a PowerShell prompt and execute `Import-Certificate -FilePath ".\Desktop\wordpress.test.crt" -CertStoreLocation Cert:\CurrentUser\Root`


## Setting up the local system

### 1. run `./setup.sh`

This will configure your host-file and create the necessary config files first.
You will likely need to enter your sudo password as this will add basic.wordpress.test etc to your hosts file. (see note above for windows)

### 2. run `./start.sh`

This will create and start your containers. You can visit your environment by visiting `https://basic.wordpress.test`. Note that starting other containers, like woocommerce or multisite, will have different domains associated.

### Resetting everything

You can always run `./clean.sh` to delete all persistent data of your WordPresss environment and start again from scratch. If you run `./clean.sh --all` you will also remove configuration files.

## Maintenance and CLI commands

### Running alternate or multiple containers

By default `./start.sh` will start the basic wordpress container. Alternatively you can call `./start.sh $CONTAINER_NAMES` to start other containers.

The following are available:

- **basic-wordpress**: The basic image that's started by default. Can be accessed via basic.wordpress.test.
- **standalone-wordpress**: The basic image without anything installed. Has a separate plugins folder named `sa-plugins` in order to not interfere with other containers. Useful for testing a second version of a plugin.
- **woocommerce-wordpress**: A WooCommerce installation. Can be accessed via woocommerce.wordpress.test.
- **multisite-wordpress**: A multisite installation using subdirectories. Can be accessed via multisite.wordpress.test.
- **multisitedomain-wordpress**: A multisite installation using subdomains. Can be accessed via multisite.wordpress.test.
- **nightly-wordpress**: A nightly installation using subdomains. Can be accessed via nightly.wordpress.test.

For example, calling `./start.sh woocommerce-wordpress` will start only the WooCommerce container. Calling `./start.sh basic-wordpress multisite-wordpress` will start both the basic WordPress and multisite containers.


### Running WordPress trunk, beta or RC

If you need WordPress trunk, a beta or a release candidate, there are two ways of going about that:

- Switch using WP CLI:

  ```bash
  ./wp.sh core update --version=nightly
  ```

Note that you'll have to repeat this daily if you want to be on the latest nightly. If you want to switch back, do, note the `--force` because you're downgrading:

  ```bash
  ./wp.sh core update --version=5.4 --force
  ./wp.sh core update --version=5.4 --force
  ```

- Install and use the [WordPress beta tester plugin](https://wordpress.org/plugins/wordpress-beta-tester/).
  
#### Setting up your plugins

Run `./plugins.sh` - this will install default plugins to your container for easier debugging and developing.
Simply clone, extract or download any plugins you want available in your environment into the `plugins` directory. They will be immediately visible inside your WordPress installation. Don't forget to activate them!

#### Running WP CLI commands

You can run `./wp.sh` to run WP CLI commands. By default this will execute the command in the first running WordPress container ( created from this project ). However if the first argument is the name of a container it will specifically run in that container.

For example: `./wp.sh shell` will run `wp shell` in the first active WordPress installation. `./wp.sh woocommerce-wordpress cache flush` will run `wp cache flush` in the woocommerce-wordpresss installation.

#### Mails and mailhog

Mailhog is a local catch-all for mails that are sent from local environments. To use it, use WordPress like you would normally. For example, create a new user and have the installation send an e-mail to the user. This will deliver the mail to your local Mailhog instance. To see this mail, open a new browsertab and navigate to [http://localhost:8025/](http://localhost:8025/). Here you will find all mails that are sent by the application.

Remember that Mailhogs' memory is non-persistent. Closing down the container will wipe all stored e-mails.

#### Updating your local WordPress installation

The local WordPress site won't be updated automatically. You have a few options to update your installation, with some pros and cons.

1) The simplest way to update your WordPress installation is to click the update button in the WP admin. This process makes sure that you keep your data (like posts, plugins etc).
2) A bit more forced way of updating (and resetting your database) can be accomplished with the following commands:

```bash
  ./clean.sh && 
  ./start.sh
```

1) If one of the methods fails, please contact the DevOps team. We can help you with updating specific docker images.

_You might add the specific container argument after the ``./start.sh`` command._

## WordPress Debugging

The docker environments come preconfigured with WordPress debugging on. If you want to enable Yoast debugging specifically, you can add the parameter `yoastdebug` to your URL. This will trigger the yoast debugging constants and show debugging logs on sitemaps and pretty print json-ld and such.

### XDebug

This container is already preconfigured with XDebug. The only thing left to do is to configure your IDE and browser. See the following 2 headers.

### PHPStorm

If you are using PHPStorm follow these instructions:

1. Open up `Preferences -> Languages & Frameworks -> PHP -> Servers`
1. Click the `+` icon
1. Name: Give it a recognizeable name or use the following Host.
1. Host: `<domain name here>` (default for this docker: `basic.wordpress.test`)
1. Port: 80
1. File/Directory `plugins/<your-plugin-name>` maps to the absoulte path `/mnt/plugins/<your-plugin-name>`.
1. File/Directory `wordpress` maps to the absoulte path `/var/www/html`.
1. Apply

In PHPStorm you can also add the `wordpress` directory to provide full WordPress indexation.

### Visual Studio Code

If you are using VSCode simply copy/paste the following `launch.json` ( don't forget to edit `<your-plugin-name` ) which you can edit by running `Debug: open launch.json`:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Listen for XDebug",
            "type": "php",
            "request": "launch",
            "port": 9000,
            "pathMappings": {
                "/var/www/html/wp-content/plugins/<your-plugin-name>": "${workspaceRoot}",
                "/var/www/html": "${workspaceRoot}/../../wordpress",
            },
        }
    ]
}
```

This assumes your plugin is the root of your opened VSCode project.

Also make sure you have the [XDebug extension installed](https://marketplace.visualstudio.com/items?itemName=felixfbecker.php-debug)!

#### Browser

For Firefox you'll want to [install the Firefox XDebug helper](https://addons.mozilla.org/en-US/firefox/addon/xdebug-helper-for-firefox/).
For Chrome you'll want to [install the Chrome XDebug helper](https://chrome.google.com/webstore/detail/xdebug-helper/eadndfjplgieldjbigjakmdgkmoaaaoc?hl=en).

Both of these do exactly the same. They add an icon to your URL bar where you can choose the XDebug settings for your request:

- Setting it to `Debug` will make PHP pause on any breakpoints you've configured in your IDE ( provided you're listening to Debug connections ).
- Setting it to `Profile` will make PHP time every function call and output a cachegrind file. These will be located in the `data/xdebug` directory.
  - These can be opened with a tool called KCachegrind / QCachegrind. On Mac you can install it using `brew install qcachegrind`. On Linux you can usually install it using `sudo apt install kcachegrind`.
- Setting it to `Trace` will make PHP output a full trace of every function call. These will also be located in the `data/xdebug` directory.
  - By default parameters and return values are not included in traces. You can change these settings by changing your `config/php.ini`. For documentation on which values to change see [the XDebug documentation](https://xdebug.org/docs/execution_trace).
  - For viewing these files with a GUI you could use [xdebug-trace-tree](https://github.com/splitbrain/xdebug-trace-tree). Cloning that project in the `wordpress` directory and visiting `http://local.wordpress.test/xdebug-trace-tree` should get you up and running.

### Connecting to the database

All database ports are forwarded to localhost to make them easily accessible from various tools. You'll want to enter the following configuration:

| Property | Value     |
| -------- | --------- |
| Host     | 127.0.0.1 |
| Username | wordpress |
| Password | wordpress |
| Database | wordpress |

The port differs based on the installation you're running.

| Site                      | Port |
|---------------------------|------|
| basic-wordpress           | 1987 |
| woocommerce-wordpress     | 1988 |
| multisite-wordpress       | 1989 |
| standalone-wordpress      | 1990 |
| multisitedomain-wordpress | 1991 |
| nightly-wordpress         | 1992 |


## Branch `introduce-caching-containers`:
This branch contains additional containers to test with Memcached and Redis caching systems. It also contains a dashboard to investigate and control the contents of each caching system. It requires the W3 total cache plugin for configuration (automatically installed on boot).

### Setup instructions
- When still on the `main` branch, make sure you have the latest pull
- Checkout `introduce-caching-containers` and pull
- Run `./clean.sh`
- Run `./setup.sh`
- Start the containers with `docker-compose up --build`
- Give the containers some time to pull, build and start
- Open https://basic.wordpress.test/ to verify the site is working
- open http://localhost:8090/ to verify the caching dashboard is working

So far the setup of the containers. Now you will need to configure W3 Total Cache (W3TC from hereon) for the different caching methods.

- In your WordPress admin, you should see `Performance` in the sidebar, this is from the W3TC plugin.
- Go to `Performance -> General settings` (it is possible you will need to skip the setup wizard)
- Here you will get a long page with different blocks. You can enable cache with either Memcached or Redis for the following caches (each having its own block on this page):
  - Page cache
  - Database cache
  - Object cache
- Just check the `Enable` checkmark and select the caching method under each option (make sure to save your settings).
- For each of the enabled caches, you have an item with the corresponding name in the menu in the sidebar
- Visit each of these menu items and look for an option named `Memcached/Redis hostname:port / IP:port:` which will have a value of `127.0.0.1:#####`
  - If you have selected Memcached for this caching option, change the value to `memcached:11211`
  - If you have selected Redis for this caching option, change the value to `redis:6379`

That is all there is to it. Set the caching method that you want to test for the cache you want. You can use the dashboard at http://localhost:8090/ to check if caches are wiped or changed.

### tips
- If you want to quickly switch between caching options, first set up all options for memcached and their correct values, then do the same for Redis. Now you only need to change the caching method on the `General settings` page without having to redo all the host:port options.
- At the bottom of the `General settings` page, there is an option to export and import options. Set up the caching methods like above and export the options now to be able to import them in a clean installation and skip all host:port setup steps.

## Troubleshooting

### WordPress is not installed (completely)

The first run after a make can fail. Quit all docker containers with `docker-compose down` and run `bash start.sh` again.

Issue: [https://github.com/Yoast/plugin-development-docker/issues/11](https://github.com/Yoast/plugin-development-docker/issues/11)

