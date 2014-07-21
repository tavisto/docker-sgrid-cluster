#!/bin/sh
docker_cmd=`which docker`
while getopts "c" flag
do
    case "$flag" in
        c) clean=1;echo "Running Clean";;
    esac
done

run_dir='./run'
if [ ! -d $run_dir ]; then
    mkdir $run_dir;
fi


if [[ $clean -gt 0 ]]; then
    echo "Removing images before rebuilding"
    $docker_cmd rmi -f sgrid-base
    $docker_cmd rmi -f sgrid-hub
    $docker_cmd rmi -f sgrid-ff-node
fi

$docker_cmd build -t sgrid-base ./sgrid-base
$docker_cmd build -t sgrid-hub ./sgrid-hub
$docker_cmd build -t sgrid-ff-node ./sgrid-firefox-node
