#!/bin/bash

# This script installs dotup bash essentials into your script folder and makes it available global

# bash <(wget -qO- https://raw.githubusercontent.com/dotupNET/DotupBashEssentials/master/DotupBashEssentials.sh)

cd /tmp
rm DotupBashEssentials*
wget https://raw.githubusercontent.com/dotupNET/DotupBashEssentials/master/DotupBashEssentials.sh

. DotupBashEssentials.sh

scriptFolder=$(Ask "Enter path to store bash scripts" "~/scripts")
targetFile="$scriptFolder/DotupBashEssentials.sh"

mkdir -p $scriptFolder

if [ -f $targetFile ]; then
  rm $targetFile
  yecho "Existing $targetFile deleted"
fi

mv DotupBashEssentials.sh $scriptFolder

TryAddLine "\. $targetFile" ~/.bashrc

gecho "Installation completed."