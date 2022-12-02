#!/bin/bash

# imports  
. scripts/envVar.sh
. scripts/utils.sh
. scripts/createChannel.sh

FABRIC_CFG_PATH=$PWD/config
BLOCKFILE="./channel-artifacts/${CHANNEL_NAME}.block"

infoln "Joining org1 peer1.hospital1 to the channel..."
joinChannel 3
infoln "Setting anchor peer1.hospital for org2..."
setAnchorPeer 3


successln "Channel '$CHANNEL_NAME' joined"
