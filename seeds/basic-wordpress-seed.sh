#!/bin/bash
echo "$(source "${BASH_SOURCE%/*}/core-install.sh")"
echo "$(wp faker core content --pages=5)"