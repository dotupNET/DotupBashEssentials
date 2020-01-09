#!/bin/bash

# This script installs dotup bash essentials into your script folder and makes it available global

# bash <(wget -qO- https://raw.githubusercontent.com/dotupNET/DotupBashEssentials/master/DotupBashEssentials.sh)

scriptFolder=$(Ask "Enter path to store bash scripts" "~/scripts")

cd $scriptFolder
wget https://raw.githubusercontent.com/dotupNET/DotupBashEssentials/master/DotupBashEssentials.sh

chmod +x DotupBashEssentials.sh
. DotupBashEssentials.sh

TryAddLine ". $scriptFolder/DotupBashEssentials.sh" ~/.bashrc

gecho "Installation completed."