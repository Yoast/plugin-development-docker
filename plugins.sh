#!/bin/bash

# List the plugins that should be installed:
declare -a PluginList=("query-monitor" "user-switching" "https://github.com/Yoast/yoast-test-helper")

function activate_plugin {
  # Get all the running containers and store the amount
  running_containers=$(docker ps --filter "ancestor=wordpress" --filter "label=com.docker.compose.project.working_dir=$(pwd)" --format "{{.Names}}")

  for container in "${running_containers[@]}"; do
    $(echo ./wp.sh $container plugin install $1 --activate)
  done
}

function install_github_plugin {
  plugin=$1
  slug=${plugin##*/}

  if [ ! -d "./plugins/$slug" ]; then
    cd plugins
    $(echo git clone $plugin $slug)
    cd -
  fi

  cd plugins/$slug/

  if [ -f "composer.json" ]; then
    composer install
  fi

  if [ -f "package.json" ]; then
    yarn
  fi

  cd -

  activate_plugin $slug
}


for plugin in "${PluginList[@]}"; do
	echo Installing $plugin.
  if [[ $plugin == "https://github.com"* ]]; then
    install_github_plugin $plugin
  else
    if [ -d "./plugins/$plugin/.git" ]; then
		  echo "Git clone found, not installing from WordPress.org."
	  else
	    activate_plugin $plugin
	  fi
	fi
done
