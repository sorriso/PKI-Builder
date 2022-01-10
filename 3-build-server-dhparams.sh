#!/usr/bin/env zsh

echo ""
echo ""
echo "******* BEGIN BATCH DHPARAMS *********************************************************************************************"

export localPath=$(pwd)
echo $localPath

cd server

for dir in */; do

    dir=${dir%*/}

    echo "******* Batch for : $dir"

    cd $dir
    rm -rf dhparams
    mkdir dhparams

    openssl dhparam -out ./dhparams/server.dh 4096

    cd ..

done

cd ..

echo "******* END BATCH DHPARAMS *********************************************************************************************"
