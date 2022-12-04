#!/bin/bash

# imports  
. scripts/envVar.sh
. scripts/utils.sh
. scripts/createChannel.sh

FABRIC_CFG_PATH=$PWD/config
BLOCKFILE="./channel-artifacts/${CHANNEL_NAME}.block"

# infoln "Joining org2 peer to the channel..."
# joinChannel 2
infoln "Setting anchor peer for org2..."
setAnchorPeer 2


successln "Channel '$CHANNEL_NAME' joined"
