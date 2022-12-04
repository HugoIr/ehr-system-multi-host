#!/bin/bash

source scripts/utils.sh
. scripts/deployCC.sh

# package the chaincode
packageChaincode

## Install chaincode on peer0.hospital and peer0.org2
infoln "Installing chaincode on peer0.hospital..."
installChaincode 1

# query whether the chaincode is installed
queryInstalled 1