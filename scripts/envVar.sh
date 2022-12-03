#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

# imports
. scripts/utils.sh

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_ORG1_CA=${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls/ca.crt
export PEER1_ORG1_CA=${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/consortium/crypto-config/peerOrganizations/insurance/peers/peer0.insurance/tls/ca.crt
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/tls-34.101.204.172-9054-ca-orderer.pem
export CORE_PEER_MSPCONFIGPATH=${PWD}/consortium/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp

# Set environment variables for the peer org
setGlobals() {
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  
  if [ $USING_ORG -eq 1 ]; then
    export CORE_PEER_LOCALMSPID="HospitalMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/consortium/crypto-config/peerOrganizations/hospital/users/Admin@hospital/msp
    export CORE_PEER_ADDRESS=peer0.hospital:7051
    infoln "Using organization 1"
  elif [ $USING_ORG -eq 2 ]; then
    export CORE_PEER_LOCALMSPID="InsuranceMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/consortium/crypto-config/peerOrganizations/insurance/users/Admin@insurance/msp
    export CORE_PEER_ADDRESS=peer0.insurance:9051
    infoln "Using organization 2"
  elif [ $USING_ORG -eq 3 ]; then
    export CORE_PEER_LOCALMSPID="HospitalMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/consortium/crypto-config/peerOrganizations/hospital/users/Admin@hospital/msp
    export CORE_PEER_ADDRESS=peer1.hospital:8051
    infoln "Using organization 1"
  else
    errorln "ORG Unknown"
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

# Set environment variables for use in the CLI container 
setGlobalsCLI() {
  setGlobals $1

  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  if [ $USING_ORG -eq 1 ]; then
    export CORE_PEER_ADDRESS=peer0.hospital:7051
  elif [ $USING_ORG -eq 2 ]; then
    export CORE_PEER_ADDRESS=peer0.insurance:9051
  elif [ $USING_ORG -eq 3 ]; then
    export CORE_PEER_ADDRESS=peer1.hospital:8051
  else
    errorln "ORG Unknown"
  fi
}

# parsePeerConnectionParameters $@
# Helper function that sets the peer connection parameters for a chaincode
# operation
parsePeerConnectionParameters() {
  PEER_CONN_PARMS=""
  PEERS=""
  while [ "$#" -gt 0 ]; do
    setGlobals $1
    if [ $1 -eq 3 ]; then
      PEER="peer1.org1"
    else
      PEER="peer0.org$1"
    fi
    ## Set peer addresses
    PEERS="$PEERS $PEER"
    PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses $CORE_PEER_ADDRESS"
    ## Set path to TLS certificate
    if [ $1 -eq 3 ]; then
      TLSINFO=$(eval echo "--tlsRootCertFiles \$PEER1_ORG1_CA")
    else
      TLSINFO=$(eval echo "--tlsRootCertFiles \$PEER0_ORG$1_CA")
    fi
    PEER_CONN_PARMS="$PEER_CONN_PARMS $TLSINFO"
    # shift by one to get to the next organization
    shift
  done
  # remove leading space for output
  PEERS="$(echo -e "$PEERS" | sed -e 's/^[[:space:]]*//')"
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    fatalln "$2"
  fi
}
