#!/bin/bash

# port to expose hub over, e.g. use 4445 and let vagrant route that back
# through 4444 if running grid in a vagrant vm
HUB_PORT="4444"
if [ "$2" != "" ]; then
    HUB_PORT=$2
fi

HUB_IMAGE="sgrid-hub"
HUB_NAME="sgrid-hub"
NODE_IMAGE="sgrid-ff-node"

DEFAULT_NODES=3

RUN_DIR='./run'
HUB_CID_PATH="$RUN_DIR/selenium-hub.cid"

function startHub() {
    if [ -f $HUB_CID_PATH ]; then
        echo "Hub already running"
        exit 1
    fi
    docker run --name $HUB_NAME -d -p $HUB_PORT:4444 --cidfile $HUB_CID_PATH $HUB_IMAGE
}

function stopHub() {
    if [ ! -f $HUB_CID_PATH ]; then
        echo "Hub already stopped"
        exit 1
    fi
    docker stop $(cat $HUB_CID_PATH) && docker rm $HUB_NAME
    rm $HUB_CID_PATH
}

function startNode() {
    if [ ! -f $HUB_CID_PATH ]; then
        echo "Hub not running"
        exit 1
    fi

    HUB_ID=$(cat $HUB_CID_PATH)
    docker run -d --link "$HUB_NAME:hub" $NODE_IMAGE
}

function stopNode() {
    if [ $(docker ps | grep $NODE_IMAGE | wc -l) == "0" ]; then
        echo "no nodes to stop"
        return
    fi
    ID=$(docker ps | grep $NODE_IMAGE | tail -n 1 | awk '{print $1}')

    docker stop $ID
}

function start() {
    if [ ! -f $HUB_CID_PATH ]; then
        startHub
    fi

    while [ $(docker ps | grep $NODE_IMAGE | wc -l) -lt $DEFAULT_NODES ]; do
        startNode
    done
}

function stop() {
    while [ $(docker ps | grep $NODE_IMAGE | wc -l) -gt 0 ]; do
        stopNode
    done

    if [ -f $HUB_CID_PATH ]; then
        stopHub
    fi
    cleanAll
}

function status() {
    if [ -f $HUB_CID_PATH ]; then
        echo "Hub:  "$(cat $HUB_CID_PATH)
    else
        echo "Hub:  not running"
        return
    fi

    for ID in $(docker ps | grep $NODE_IMAGE | awk '{print $1}'); do
        echo "node: $ID"
    done
}

function cleanAll() {
    docker ps -a | grep 'Exited' | awk '{print $1}' | xargs docker rm
}


function usage() {
    echo "Usage:    `basename $0` <action>"
    echo
    echo "ex:       `basename $0` start"
    echo
    echo "Actions:  start       start up a grid with 3 nodes"
    echo "          stop        tear down whatever is running"
    echo "          status      list running container types and their ids"
    echo "          startHub    start the hub container"
    echo "          stopHub     stop the hub container"
    echo "          startNode   add a new node to the grid"
    echo "          stopNode    remove a node from the grid"
    echo "          cleanAll    remove all old nodes"
}

case $1 in
    start)
        start;;
    stop)
        stop;;
    status)
        status;;
    startHub)
        startHub;;
    stopHub)
        stopHub;;
    startNode)
        startNode;;
    stopNode)
        stopNode;;
    cleanAll)
        cleanAll;;
    *)
        usage
        exit 1
    ;;

esac
