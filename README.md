# WordPress Plugin Development Docker

This is a fairly simple docker container to facilitate development of WordPress plugins.

### Prerequisites

Mac users:
- [Docker Desktop](https://docs.docker.com/docker-for-mac/install/) includes everything you need.

Otherwise install:
- [Docker](https://docs.docker.com/v17.09/engine/installation/)
- [docker-compose](https://docs.docker.com/compose/install/)

## Setting up the container

#### 1. run `./make.sh`
This will configure your host-file and create the necessary config files first.
You will likely need to enter your sudo password as this will add local.wordpress.test to your hosts file.

#### 2. run `./start.sh`
This will create and start your containers. Your browser will automatically open with your WordPress environment.

#### Resetting everything
You can always run `./clean.sh` to delete all persistent data of your WordPresss environment and start again from scratch.

## Maintenance and CLI commands

#### Running alternate containers

By default `./start.sh` will start the basic wordpress container. Alternatively you can call `./start.sh $CONTAINER_NAMES` to start other containers.

The following are available:
- basic-wordpress: The basic image that's started by default. Can be accessed via basic.wordpress.test.
- woocommerce-wordpress: A WooCommerce installation. Can be accessed via woocommerce.wordpress.test.
- multisite-wordpress: A multisite installation. Can be accessed via multisite.wordpress.test.

For example, calling `./start.sh woocommerce-wordpress` will start only the WooCommerce container. Calling `./start.sh basic-wordpress multisite-wordpress` will start both the basic WordPress and multisite containers.

#### Running WordPress trunk, beta or RC

If you need WordPress trunk, a beta or a release candidate, there are two ways of going about that:

- Switch using WP CLI: 
  ```bash
  ./wp.sh core update --version=nightly
  ```
  Note that you'll have to repeat this daily if you want to be on the latest nightly. If you want to switch back, do, note the `--force` because you're downgrading:
  ```bash
  ./wp.sh core update --version=5.4 --force
  ß./wp.sh core update --version=5.4 --force
  ```
- Install and use the [WordPress beta tester plugin](https://wordpress.org/plugins/wordpress-beta-tester/).
  
#### Setting up your plugins.

Run `./plugins.sh` - this will install default plugins to your container for easier debugging and developing.
Simply clone, extract or download any plugins you want available in your environment into the `plugins` directory. They will be immediately visible inside your WordPress installation. Don't forget to activate them!

#### Running WP CLI commands.

You can run `./wp.sh` to run WP CLI commands. By default this will execute the command in the first running WordPress container ( created from this project ). However if the first argument is the name of a container it will specifically run in that container.

For example: `./wp.sh shell` will run `wp shell` in the first active WordPress installation. `./wp.sh woocommerce-wordpress cache flush` will run `wp cache flush` in the woocommerce-wordpresss installation.

#### Updating your local WordPress installation

The local WordPress site won't be updated automatically. You have a few options to update your installation, with some pros and cons.

1) The simplest way to update your WordPress installation is to click the update button in the WP admin. This process makes sure that you keep your data (like posts, plugins etc).
2) A bit more forced way of updating (and resetting your database) can be accomplished with the following commands:
```bash
  ./clean.sh && 
  ./make.sh &&
  ./start.sh
```

_You might add the specific container argument after the ``./start.sh`` command._

## WordPress Debugging 

The docker environments come preconfigured with WordPress debugging on. If you want to enable Yoast debugging specifically, you can add the parameter `yoastdebug` to your URL. This will trigger the yoast debugging constants and show debugging logs on sitemaps and pretty print json-ld and such.

#### XDebug

This container is already preconfigured with XDebug. The only thing left to do is to configure your IDE and browser. See the following 2 headers.

#### PHPStorm
If you are using PHPStorm follow these instructions:
1. Open up `Preferences -> Languages & Frameworks -> PHP -> Servers`
1. Click the `+` icon
1. Name: Give it a recognizeable name or use the following Host.
1. Host: `<domain name here>` (default for this docker: `basic.wordpress.test`)
1. Port: 80
1. File/Directory `plugins/<your-plugin-name>` maps to the absoulte path `/var/www/html/wp-content/plugins/<your-plugin-name>`.
1. File/Directory `wordpress` maps to the absoulte path `/var/www/html`.
1. Apply

In PHPStorm you can also add the `wordpress` directory to provide full WordPress indexation.

#### Visual Studio Code
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

### Connecting to the database.

All database ports are forwarded to localhost to make them easily accessible from various tools. You'll want to enter the following configuration:

| Property | Value     |
| -------- | --------- |
| Host     | 127.0.0.1 |
| Username | wordpress |
| Password | wordpress |
| Database | wordpress |

The port differs based on the installation you're running.

| Site                  | Port |
| --------------------- | ---- |
| basic-wordpress       | 1987 |
| woocommerce-wordpress | 1988 |
| multisite-wordpress   | 1989 |


## Troubleshooting

### WordPress is not installed (completely)
The first run after a make can fail. Quit all docker containers with `docker-compose down` and run `bash start.sh` again.

Issue: https://github.com/Yoast/plugin-development-docker/issues/11

### Multisite main site is not working on custom domain
Changing the domain name of the multisite in `config.sh` does not work yet and causes the main site to do a redirect to the domain `multisite.wordpress.test`. Change the variable `DOMAIN_CURRENT_SITE` in `seeds/multisite-wordpress-seed.sh` to the custom domain you use and restart docker.

Issue: https://github.com/Yoast/plugin-development-docker/issues/9
