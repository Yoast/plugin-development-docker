#!/bin/bash

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

  $(echo ./wp.sh plugin install $slug --activate)
}

declare -a PluginList=("query-monitor" "user-switching" "https://github.com/Yoast/yoast-test-helper")

for plugin in "${PluginList[@]}"; do
	echo Installing $plugin.
  if [[ $plugin == "https://github.com"* ]]; then
    install_github_plugin $plugin
  else
    if [ -d "./plugins/$plugin/.git" ]; then
		  echo "Git clone found, not installing from WordPress.org."
	  else
  		$(echo ./wp.sh plugin install $plugin --activate)
	  fi
	fi
done
