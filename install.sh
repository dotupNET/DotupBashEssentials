#!/bin/bash

# This script installs dotup bash essentials into your script folder and makes it available global

# bash <(wget -qO- https://raw.githubusercontent.com/dotupNET/DotupBashEssentials/master/DotupBashEssentials.sh)

cd /tmp
wget https://raw.githubusercontent.com/dotupNET/DotupBashEssentials/master/DotupBashEssentials.sh

. DotupBashEssentials.sh

scriptFolder=$(Ask "Enter path to store bash scripts" "~/scripts")

mkdir -p $scriptFolder
mv DotupBashEssentials.sh $scriptFolder

TryAddLine ". ${scriptFolder}/DotupBashEssentials.sh" ~/.bashrc

gecho "Installation completed."