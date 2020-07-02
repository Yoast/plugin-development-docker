#!/bin/bash

declare -a PluginList=("query-monitor" "user-switching" "yoast-test-helper")

# Install each plugin
for plugin in "${PluginList[@]}"; do
	echo Installing $plugin.
	if [ -d "./plugins/$plugin/.git" ]; then
		echo "Git clone found, not installing from WordPress.org."
	else 
		$(echo ./wp.sh plugin install $plugin --activate)
	fi
done

