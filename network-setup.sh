#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This script brings up a Hyperledger Fabric network for testing smart contracts
# and applications. The test network consists of two organizations with one
# peer each, and a single node Raft ordering service. Users can also use this
# script to create a channel deploy a chaincode on the channel
#
# prepending $PWD/../bin to PATH to ensure we are picking up the correct binaries
# this may be commented out to resolve installed version of tools if desired
export PATH=${PWD}/bin:$PATH
export FABRIC_CFG_PATH=${PWD}/configtx
export VERBOSE=false

source scripts/utils.sh

# Obtain the OS and Architecture string that will be used to select the correct
# native binaries for your platform, e.g., darwin-amd64 or linux-amd64
OS_ARCH=$(echo "$(uname -s | tr '[:upper:]' '[:lower:]' | sed 's/mingw64_nt.*/windows/')-$(uname -m | sed 's/x86_64/amd64/g')" | awk '{print tolower($0)}')
# Using crpto vs CA. default is cryptogen
CRYPTO="cryptogen"
# timeout duration - the duration the CLI should wait for a response from
# another container before giving up
MAX_RETRY=5
# default for delay between commands
CLI_DELAY=3
# channel name defaults to "mychannel"
CHANNEL_NAME="hospital-channel"
# chaincode name defaults to "NA"
CC_NAME="fab-healthcare"
# chaincode path defaults to "NA"
CC_SRC_PATH="chaincode/ehr/javascript/"
# endorsement policy defaults to "NA". This would allow chaincodes to use the majority default policy.
CC_END_POLICY="NA"
# collection configuration defaults to "NA"
# CC_COLL_CONFIG="./chaincode-asset-transfer/collection_config.json"
CC_COLL_CONFIG="NA"
# chaincode init function defaults to "NA"
CC_INIT_FCN="initLedger"
# CC_INIT_FCN="NA"
# use this as the default docker-compose yaml definition
COMPOSE_FILE_BASE=docker/docker-compose-net.yaml

# docker-compose.yaml file if you are using couchdb
COMPOSE_FILE_COUCH=docker/docker-compose-couch.yaml
# certificate authorities compose file
COMPOSE_FILE_CA=docker/docker-compose-ca.yaml

# use this as the docker compose couch file for org3
COMPOSE_FILE_COUCH_ORG3=addOrg3/docker/docker-compose-couch-org3.yaml
# use this as the default docker-compose yaml definition for org3
COMPOSE_FILE_ORG3=addOrg3/docker/docker-compose-org3.yaml
#
# chaincode language defaults to "NA"
CC_SRC_LANGUAGE="javascript"
# Chaincode version
CC_VERSION="1.0"
# Chaincode definition sequence
CC_SEQUENCE=1
# default image tag
IMAGETAG="latest"
# default ca image tag
CA_IMAGETAG="latest"
# default database
DATABASE="couchdb"

NETWORK_DOCKER=docker/docker-compose-net.yaml

# Obtain CONTAINER_IDS and remove them
# TODO Might want to make this optional - could clear other containers
# This function is called when you bring a network down
function clearContainers() {
  CONTAINER_IDS=$(docker ps -a | awk '($2 ~ /dev-peer.*/) {print $1}')
  if [ -z "$CONTAINER_IDS" -o "$CONTAINER_IDS" == " " ]; then
    infoln "No containers available for deletion"
  else
    docker rm -f $CONTAINER_IDS
  fi
}


## Call the script to deploy a chaincode to the channel
function deployCC() {
  scripts/deployCC.sh $CHANNEL_NAME $CC_NAME $CC_SRC_PATH $CC_SRC_LANGUAGE $CC_VERSION $CC_SEQUENCE $CC_INIT_FCN $CC_END_POLICY $CC_COLL_CONFIG $CLI_DELAY $MAX_RETRY $VERBOSE

  if [ $? -ne 0 ]; then
    fatalln "Deploying chaincode failed"
  fi
}


# Generate orderer system channel genesis block.
function createConsortium() {
  which configtxgen
  if [ "$?" -ne 0 ]; then
    fatalln "configtxgen tool not found."
  fi

  infoln "Generating Orderer Genesis block"

  # Note: For some unknown reason (at least for now) the block file can't be
  # named orderer.genesis.block or the orderer will fail to launch!
  set -x
  configtxgen -profile TwoOrgsOrdererGenesis -channelID system-channel -outputBlock ./system-genesis-block/genesis.block
  res=$?
  { set +x; } 2>/dev/null
  if [ $res -ne 0 ]; then
    fatalln "Failed to generate orderer genesis block..."
  fi
}

# Delete any images that were generated as a part of this setup
# specifically the following images are often left behind:
# This function is called when you bring the network down
function removeUnwantedImages() {
  DOCKER_IMAGE_IDS=$(docker images | awk '($1 ~ /dev-peer.*/) {print $3}')
  if [ -z "$DOCKER_IMAGE_IDS" -o "$DOCKER_IMAGE_IDS" == " " ]; then
    infoln "No images available for deletion"
  else
    docker rmi -f $DOCKER_IMAGE_IDS
  fi
}

# Versions of fabric known not to work with the test network
NONWORKING_VERSIONS="^1\.0\. ^1\.1\. ^1\.2\. ^1\.3\. ^1\.4\."

# function checkPrereqs() {
#   ## Check if your have cloned the peer binaries and configuration files.
#   peer version > /dev/null 2>&1

#   if [[ $? -ne 0 || ! -d "../config" ]]; then
#     errorln "Peer binary and configuration files not found.."
#     errorln
#     errorln "Follow the instructions in the Fabric docs to install the Fabric Binaries:"
#     errorln "https://hyperledger-fabric.readthedocs.io/en/latest/install.html"
#     exit 1
#   fi
#   # use the fabric tools container to see if the samples and binaries match your
#   # docker images
#   LOCAL_VERSION=$(peer version | sed -ne 's/^ Version: //p')
#   DOCKER_IMAGE_VERSION=$(docker run --rm hyperledger/fabric-tools:$IMAGETAG peer version | sed -ne 's/^ Version: //p')

#   infoln "LOCAL_VERSION=$LOCAL_VERSION"
#   infoln "DOCKER_IMAGE_VERSION=$DOCKER_IMAGE_VERSION"

#   if [ "$LOCAL_VERSION" != "$DOCKER_IMAGE_VERSION" ]; then
#     warnln "Local fabric binaries and docker images are out of  sync. This may cause problems."
#   fi

#   for UNSUPPORTED_VERSION in $NONWORKING_VERSIONS; do
#     infoln "$LOCAL_VERSION" | grep -q $UNSUPPORTED_VERSION
#     if [ $? -eq 0 ]; then
#       fatalln "Local Fabric binary version of $LOCAL_VERSION does not match the versions supported by the test network."
#     fi

#     infoln "$DOCKER_IMAGE_VERSION" | grep -q $UNSUPPORTED_VERSION
#     if [ $? -eq 0 ]; then
#       fatalln "Fabric Docker image version of $DOCKER_IMAGE_VERSION does not match the versions supported by the test network."
#     fi
#   done

#   ## Check for fabric-ca
#   if [ "$CRYPTO" == "Certificate Authorities" ]; then

#     fabric-ca-client version > /dev/null 2>&1
#     if [[ $? -ne 0 ]]; then
#       errorln "fabric-ca-client binary not found.."
#       errorln
#       errorln "Follow the instructions in the Fabric docs to install the Fabric Binaries:"
#       errorln "https://hyperledger-fabric.readthedocs.io/en/latest/install.html"
#       exit 1
#     fi
#     CA_LOCAL_VERSION=$(fabric-ca-client version | sed -ne 's/ Version: //p')
#     CA_DOCKER_IMAGE_VERSION=$(docker run --rm hyperledger/fabric-ca:$CA_IMAGETAG fabric-ca-client version | sed -ne 's/ Version: //p' | head -1)
#     infoln "CA_LOCAL_VERSION=$CA_LOCAL_VERSION"
#     infoln "CA_DOCKER_IMAGE_VERSION=$CA_DOCKER_IMAGE_VERSION"

#     if [ "$CA_LOCAL_VERSION" != "$CA_DOCKER_IMAGE_VERSION" ]; then
#       warnln "Local fabric-ca binaries and docker images are out of sync. This may cause problems."
#     fi
#   fi
# }


# Create Organization crypto material using cryptogen or CAs
function createOrgs() {
  if [ -d "consortium/crypto-config/peerOrganizations" ]; then
    rm -Rf consortium/crypto-config/peerOrganizations && rm -Rf consortium/crypto-config/ordererOrganizations
  fi

  # Create crypto material using cryptogen
  if [ "$CRYPTO" == "cryptogen" ]; then
    which cryptogen
    if [ "$?" -ne 0 ]; then
      fatalln "cryptogen tool not found. exiting"
    fi
    infoln "Generating certificates using cryptogen tool"

    infoln "Creating Org1 Identities"

    set -x
    cryptogen generate --config=./consortium/crypto-config/cryptogen/crypto-config-org1.yaml --output="organizations"
    res=$?
    { set +x; } 2>/dev/null
    if [ $res -ne 0 ]; then
      fatalln "Failed to generate certificates..."
    fi

    infoln "Creating Org2 Identities"

    set -x
    cryptogen generate --config=consortium/crypto-config/cryptogen/crypto-config-org2.yaml --output="organizations"
    res=$?
    { set +x; } 2>/dev/null
    if [ $res -ne 0 ]; then
      fatalln "Failed to generate certificates..."
    fi

    infoln "Creating Orderer Org Identities"

    set -x
    cryptogen generate --config=consortium/crypto-config/cryptogen/crypto-config-orderer.yaml --output="organizations"
    res=$?
    { set +x; } 2>/dev/null
    if [ $res -ne 0 ]; then
      fatalln "Failed to generate certificates..."
    fi

  fi

  # Create crypto material using Fabric CA
  if [ "$CRYPTO" == "Certificate Authorities" ]; then
    infoln "Generating certificates using Fabric CA"

    IMAGE_TAG=${CA_IMAGETAG} docker-compose -f $COMPOSE_FILE_CA up -d 2>&1

    . consortium/crypto-config/fabric-ca/registerEnroll.sh

  while :
    do
      if [ ! -f "consortium/fabric-ca/hospital/tls-cert.pem" ]; then
        sleep 1
      else
        break
      fi
    done

    infoln "Creating Org1 Identities"

    createOrg1

    infoln "Creating Org2 Identities"

    createOrg2

    infoln "Creating Orderer Org Identities"

    createOrderer

  fi

  infoln "Generating CCP files for Org1 and Org2"
  ./consortium/ccp-generate.sh
}


function CAServiceUp() {
  IMAGE_TAG= docker-compose -f ${COMPOSE_FILE_CA} up -d

  docker ps -a
  if [ $? -ne 0 ]; then
    fatalln "Unable to start CA Service"
  fi
}

# Bring up the peer and orderer nodes using docker compose.
function networkUp() {
  
  COMPOSE_FILES="-f ${NETWORK_DOCKER}"

  if [ "${DATABASE}" == "couchdb" ]; then
    COMPOSE_FILES="${COMPOSE_FILES} -f ${COMPOSE_FILE_COUCH}"
  fi

  IMAGE_TAG= docker-compose $COMPOSE_FILES up -d 2>&1

  docker ps -a
  if [ $? -ne 0 ]; then
    fatalln "Unable to start network"
  fi
}

function networkUpOrderer() {
  
  COMPOSE_FILES="-f ${NETWORK_DOCKER}"

  if [ "${DATABASE}" == "couchdb" ]; then
    COMPOSE_FILES="${COMPOSE_FILES}"
  fi

  IMAGE_TAG= docker-compose $COMPOSE_FILES up -d 2>&1

  docker ps -a
  if [ $? -ne 0 ]; then
    fatalln "Unable to start network"
  fi
}

# call the script to create the channel, join the peers of org1 and org2,
# and then update the anchor peers for each organization
function createChannel() {
  # Bring up the network if it is not already up.

  if [ ! -d "consortium/crypto-config/peerOrganizations" ]; then
    infoln "Bringing up network"
    networkUp
  fi

  # now run the script that creates a channel. This script uses configtxgen once
  # more to create the channel creation transaction and the anchor peer updates.
  # configtx.yaml is mounted in the cli container, which allows us to use it to
  # create the channel artifacts
  scripts/$1.sh $CHANNEL_NAME $CLI_DELAY $MAX_RETRY $VERBOSE
}



# Tear down running network
function networkDown() {
  # stop org3 containers also in addition to org1 and org2, in case we were running sample to add org3
  docker-compose -f $COMPOSE_FILE_BASE -f $COMPOSE_FILE_COUCH -f $COMPOSE_FILE_CA down --volumes --remove-orphans
  docker-compose -f $COMPOSE_FILE_COUCH_ORG3 -f $COMPOSE_FILE_ORG3 down --volumes --remove-orphans
  # Don't remove the generated artifacts -- note, the ledgers are always removed
  if [ "$MODE" != "restart" ]; then
    # Bring down the network, deleting the volumes
    #Cleanup the chaincode containers
    clearContainers
    #Cleanup images
    removeUnwantedImages
    # remove orderer block and other channel configuration transactions and certs
    docker run --rm -v $(pwd):/data busybox sh -c 'cd /data && rm -rf system-genesis-block/*.block consortium/crypto-config/peerOrganizations consortium/crypto-config/ordererOrganizations'
    ## remove fabric ca artifacts
    docker run --rm -v $(pwd):/data busybox sh -c 'cd /data && rm -rf consortium/fabric-ca/hospital/msp consortium/fabric-ca/hospital/tls-cert.pem consortium/fabric-ca/hospital/ca-cert.pem consortium/fabric-ca/hospital/IssuerPublicKey consortium/fabric-ca/hospital/IssuerRevocationPublicKey consortium/fabric-ca/hospital/fabric-ca-server.db'
    docker run --rm -v $(pwd):/data busybox sh -c 'cd /data && rm -rf consortium/fabric-ca/insurance/msp consortium/fabric-ca/insurance/tls-cert.pem consortium/fabric-ca/insurance/ca-cert.pem consortium/fabric-ca/insurance/IssuerPublicKey consortium/fabric-ca/insurance/IssuerRevocationPublicKey consortium/fabric-ca/insurance/fabric-ca-server.db'
    docker run --rm -v $(pwd):/data busybox sh -c 'cd /data && rm -rf consortium/fabric-ca/ordererOrg/msp consortium/fabric-ca/ordererOrg/tls-cert.pem consortium/fabric-ca/ordererOrg/ca-cert.pem consortium/fabric-ca/ordererOrg/IssuerPublicKey consortium/fabric-ca/ordererOrg/IssuerRevocationPublicKey consortium/fabric-ca/ordererOrg/fabric-ca-server.db'
    # gaperlu KEKNYA
    # docker run --rm -v $(pwd):/data busybox sh -c 'cd /data && rm -rf addOrg3/fabric-ca/org3/msp addOrg3/fabric-ca/org3/tls-cert.pem addOrg3/fabric-ca/org3/ca-cert.pem addOrg3/fabric-ca/org3/IssuerPublicKey addOrg3/fabric-ca/org3/IssuerRevocationPublicKey addOrg3/fabric-ca/org3/fabric-ca-server.db'

    # remove channel and script artifacts
    docker run --rm -v $(pwd):/data busybox sh -c 'cd /data && rm -rf channel-artifacts log.txt *.tar.gz'
  fi
}

# Parse commandline args

## Parse mode
if [[ $# -lt 1 ]] ; then
  printHelp
  exit 0
else
  MODE=$1
  shift
fi

# parse a createChannel subcommand if used
if [[ $# -ge 1 ]] ; then
  key="$1"
  if [[ "$key" == "createChannel" ]]; then
      export MODE="createChannel"
      shift
  fi
fi

# parse flags

while [[ $# -ge 1 ]] ; do
  key="$1"
  case $key in
  -h )
    printHelp $MODE
    exit 0
    ;;
  -c )
    CHANNEL_NAME="$2"
    shift
    ;;
  -ca )
    CRYPTO="Certificate Authorities"
    ;;
  -r )
    MAX_RETRY="$2"
    shift
    ;;
  -d )
    CLI_DELAY="$2"
    shift
    ;;
  -s )
    DATABASE="$2"
    shift
    ;;
  -ccl )
    CC_SRC_LANGUAGE="$2"
    shift
    ;;
  -ccn )
    CC_NAME="$2"
    shift
    ;;
  -ccv )
    CC_VERSION="$2"
    shift
    ;;
  -ccs )
    CC_SEQUENCE="$2"
    shift
    ;;
  -ccp )
    CC_SRC_PATH="$2"
    shift
    ;;
  -ccep )
    CC_END_POLICY="$2"
    shift
    ;;
  -cccg )
    CC_COLL_CONFIG="$2"
    shift
    ;;
  -cci )
    CC_INIT_FCN="$2"
    shift
    ;;
  -i )
    IMAGETAG="$2"
    shift
    ;;
  -cai )
    CA_IMAGETAG="$2"
    shift
    ;;
  -verbose )
    VERBOSE=true
    shift
    ;;
  * )
    errorln "Unknown flag: $key"
    printHelp
    exit 1
    ;;
  esac
  shift
done

# Are we generating crypto material with this command?
if [ ! -d "consortium/crypto-config/peerOrganizations" ]; then
  CRYPTO_MODE="with crypto from '${CRYPTO}'"
else
  CRYPTO_MODE=""
fi


if [ "${MODE}" == "up-peer0hos" ]; then
  NETWORK_DOCKER=docker/docker-compose-net-peer0hospital.yaml
  COMPOSE_FILE_COUCH=docker/docker-compose-couch-peer0hospital.yaml
  createConsortium
  networkUp
elif [ "${MODE}" == "up-peer1hos" ]; then
  NETWORK_DOCKER=docker/docker-compose-net-peer1hospital.yaml
  COMPOSE_FILE_COUCH=docker/docker-compose-couch-peer1hospital.yaml
  createConsortium
  networkUp
elif [ "${MODE}" == "up-peer0ins" ]; then
  NETWORK_DOCKER=docker/docker-compose-net-peer0insurance.yaml
  COMPOSE_FILE_COUCH=docker/docker-compose-couch-peer0insurance.yaml
  createConsortium
  networkUp
elif [ "${MODE}" == "up-orderer" ]; then
  NETWORK_DOCKER=docker/docker-compose-net-orderer.yaml
  createConsortium
  networkUpOrderer
elif [ "${MODE}" == "ca-host1" ]; then
  COMPOSE_FILE_CA=docker/docker-compose-net-host1.yaml
  CAServiceUp  
elif [ "${MODE}" == "ca-hospital" ]; then
  COMPOSE_FILE_CA=docker/docker-compose-ca-hospital.yaml
  CAServiceUp
elif [ "${MODE}" == "ca-insurance" ]; then
  COMPOSE_FILE_CA=docker/docker-compose-ca-insurance.yaml
  CAServiceUp
elif [ "${MODE}" == "ca-orderer" ]; then
  COMPOSE_FILE_CA=docker/docker-compose-ca-orderer.yaml
  CAServiceUp
elif [ "${MODE}" == "channel-hospital-all" ]; then
  createChannel createChannel-all.sh  
elif [ "${MODE}" == "channel-hospital1" ]; then
  createChannel channel-peer0hospital.sh
elif [ "${MODE}" == "channel-hospital2 " ]; then
  createChannel channel-peer1hospital.sh
elif [ "${MODE}" == "channel-insurance" ]; then
  createChannel channel-peer0insurance.sh
elif [ "${MODE}" == "deployCC" ]; then
  deployCC
elif [ "${MODE}" == "down" ]; then
  networkDown
else
  printHelp
  exit 1
fi
