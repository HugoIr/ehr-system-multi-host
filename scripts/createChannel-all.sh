#!/bin/bash

# imports  
. scripts/envVar.sh
. scripts/utils.sh
. scripts/createChannel.sh


FABRIC_CFG_PATH=${PWD}/configtx

## Create channeltx
# infoln "Generating channel create transaction '${CHANNEL_NAME}.tx'"
# createChannelTx

FABRIC_CFG_PATH=$PWD/config
BLOCKFILE="./channel-artifacts/${CHANNEL_NAME}.block"

# # Create channel
# infoln "Creating channel ${CHANNEL_NAME}"
# createChannel
# successln "Channel '$CHANNEL_NAME' created"

# # Join all the peers to the channel
# infoln "Joining org1 peer to the channel..."
# joinChannel 1
# infoln "Setting anchor peer0.hospital for org1..."
# setAnchorPeer 1

# infoln "Joining org2 peer to the channel..."
# joinChannel 2

setGlobals 2
infoln "Setting anchor peer for org2..."
setAnchorPeer 2

infoln "Joining org1 peer1.hospital1 to the channel..."
joinChannel 3
infoln "Setting anchor peer1.hospital for org2..."
setAnchorPeer 3

successln "Channel '$CHANNEL_NAME' joined"

