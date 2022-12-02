#!/bin/bash

# imports  
. scripts/envVar.sh
. scripts/utils.sh

CHANNEL_NAME="$1"
DELAY="$2"
MAX_RETRY="$3"
VERBOSE="$4"
: ${CHANNEL_NAME:="hospital-channel"}
: ${DELAY:="3"}
: ${MAX_RETRY:="5"}
: ${VERBOSE:="false"}

if [ ! -d "channel-artifacts" ]; then
	mkdir channel-artifacts
fi

createChannelTx() {
	set -x
	configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME
	res=$?
	{ set +x; } 2>/dev/null
  verifyResult $res "Failed to generate channel configuration transaction..."
}

# gaperlu karena channel yang mau lu buat kan cuma 1 doang: hospital channel

# createAnchorPeerTx() {
# 	for orgmsp in HospitalMSP InsuranceMSP; do 

# 	infoln "generating transaction ${orgmsp}"
# 	set -x
# 	configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/${orgmsp}anchors.tx -channelID $CHANNEL_NAME -asOrg $orgmsp
# 	res=$?
# 	{ set +x; } 2>/dev/null
# 	infoln "generating transaction after ${orgmsp}"
# 	done
# }

createChannel() {
	setGlobals 1
	# Poll in case the raft leader is not set yet
	local rc=1
	local COUNTER=1
	# peer channel list
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
		sleep $DELAY
		set -x
		peer channel create -o localhost:7050 -c $CHANNEL_NAME --ordererTLSHostnameOverride orderer.example.com -f ./channel-artifacts/${CHANNEL_NAME}.tx --outputBlock $BLOCKFILE --tls --cafile $ORDERER_CA >&log.txt
		res=$?
		{ set +x; } 2>/dev/null
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
	verifyResult $res "Channel creation failed"
}

# joinChannel ORG
joinChannel() {
  FABRIC_CFG_PATH=$PWD/config/
  ORG=$1
  setGlobals $ORG
	local rc=1
	local COUNTER=1
	
	## Sometimes Join takes time, hence retry
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
    sleep $DELAY
    set -x
	# join by giving genesis block path
    peer channel join -b $BLOCKFILE >&log.txt
    res=$?
    { set +x; } 2>/dev/null
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
	verifyResult $res "After $MAX_RETRY attempts, peer0.org${ORG} has failed to join channel '$CHANNEL_NAME' "
}

setAnchorPeer() {
  ORG=$1
  docker exec cli ./scripts/setAnchorPeer.sh $ORG $CHANNEL_NAME 
}

FABRIC_CFG_PATH=${PWD}/configtx
