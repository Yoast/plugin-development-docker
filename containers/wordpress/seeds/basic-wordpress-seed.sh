#!/bin/bash
echo "$(source "/usr/local/bin/core-install.sh")"
echo "$(wp faker core content --pages=5)"
