# WordPress Plugin Development Docker

This is a fairly simple docker container to facilitate development of WordPress plugins.

### Prerequisites

Make sure you have [Docker installed](https://docs.docker.com/v17.09/engine/installation/) before starting. You will also need [docker-compose](https://docs.docker.com/compose/install/).

If you're on mac simply install [Docker Desktop](https://docs.docker.com/docker-for-mac/install/) it includes everything you need.

### Setting up the container.

In order to configure your host file and create the necessary config files first run `./make.sh`. You will likely need to enter your sudo password as this will add local.wordpress.test to your hosts file.

Next up run `./start.sh`. This will create and start your containers. Your browser will automatically open with your WordPress environment. If this is your first time booting the container you will enter the WordPress installation wizard to set up your admin account.

You can always run `./clean.sh` to delete all persistent data of your WordPresss environment and start again from scratch.

### Setting up your plugins.

Simply clone, extract or download any plugins you want available in your environment into the `plugins` directory. They will be immediately visible inside your WordPress installation. Don't forget to activate them!

### Setting up XDebug

This container is already preconfigured with XDebug. The only thing left to do is to configure your IDE and browser.

#### PHPStorm
If you are using PHPStorm follow these instructions:
1. Open up `Preferences -> Languages & Frameworks -> PHP -> Servers`
1. Click the `+` icon
1. Name: local.wordpress.test
1. Host: local.wordpress.test
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
