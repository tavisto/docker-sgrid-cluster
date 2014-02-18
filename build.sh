#!/bin/sh
docker_cmd='/usr/bin/docker'
while getopts "c" flag
do
    case "$flag" in
        c) clean=1;echo "Running Clean";;
    esac
done

if [[ $clean -gt 0 ]]; then
    echo "Removing images before rebuilding"
    $docker_cmd rmi sgrid-base
    $docker_cmd rmi sgrid-hub
    $docker_cmd rmi sgrid-ff-node
fi

$docker_cmd build -t sgrid-base ./sgrid-base
$docker_cmd build -t sgrid-hub ./sgrid-hub
$docker_cmd build -t sgrid-ff-node ./sgrid-firefox-node
