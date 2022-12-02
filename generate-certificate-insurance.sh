#!/bin/bash

. scripts/utils.sh
export PATH=${PWD}/bin:$PATH

function generateInsuranceCertificate() {
    echo
    echo "Enroll the insurer"
    echo
    mkdir -p consortium/crypto-config/peerOrganizations/insurance/
    export FABRIC_CA_CLIENT_HOME=${PWD}/consortium/crypto-config/peerOrganizations/insurance/

    fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca.insurance --tls.certfiles ${PWD}/consortium/fabric-ca/insurance/tls-cert.pem

    echo 'NodeOUs:
    Enable: true
    ClientOUIdentifier:
        Certificate: cacerts/localhost-8054-ca-insurance.pem
        OrganizationalUnitIdentifier: client
    PeerOUIdentifier:
        Certificate: cacerts/localhost-8054-ca-insurance.pem
        OrganizationalUnitIdentifier: peer
    AdminOUIdentifier:
        Certificate: cacerts/localhost-8054-ca-insurance.pem
        OrganizationalUnitIdentifier: admin
    OrdererOUIdentifier:
        Certificate: cacerts/localhost-8054-ca-insurance.pem
        OrganizationalUnitIdentifier: orderer' >${PWD}/consortium/crypto-config/peerOrganizations/insurance/msp/config.yaml

    infoln "Registering peer0"
    set -x
    fabric-ca-client register --caname ca.insurance --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/consortium/fabric-ca/insurance/tls-cert.pem
    { set +x; } 2>/dev/null

    infoln "Registering peer1"
    set -x
    fabric-ca-client register --caname ca.insurance --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles ${PWD}/consortium/fabric-ca/insurance/tls-cert.pem
    { set +x; } 2>/dev/null

    infoln "Registering user"
    set -x
    fabric-ca-client register --caname ca.insurance --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/consortium/fabric-ca/insurance/tls-cert.pem
    { set +x; } 2>/dev/null

    infoln "Registering the org admin"
    set -x
    fabric-ca-client register --caname ca.insurance --id.name org1admin --id.secret org1adminpw --id.type admin --tls.certfiles ${PWD}/consortium/fabric-ca/insurance/tls-cert.pem
    { set +x; } 2>/dev/null

    mkdir -p consortium/crypto-config/peerOrganizations/insurance/peers

    mkdir -p consortium/crypto-config/peerOrganizations/insurance/peers/peer0.insurance

    # Peer 0
    infoln "Generating the peer0 msp"
    set -x
    fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca.insurance -M ${PWD}/consortium/crypto-config/peerOrganizations/insurance/peers/peer0.insurance/msp --csr.hosts peer0.insurance --tls.certfiles ${PWD}/consortium/fabric-ca/insurance/tls-cert.pem
    { set +x; } 2>/dev/null

    cp ${PWD}/consortium/crypto-config/peerOrganizations/insurance/msp/config.yaml ${PWD}/consortium/crypto-config/peerOrganizations/insurance/peers/peer0.insurance/msp/config.yaml

    infoln "Generating the peer0-tls certificates"
    set -x
    fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca.insurance -M ${PWD}/consortium/crypto-config/peerOrganizations/insurance/peers/peer0.insurance/tls --enrollment.profile tls --csr.hosts peer0.insurance --csr.hosts localhost --tls.certfiles ${PWD}/consortium/fabric-ca/insurance/tls-cert.pem
    { set +x; } 2>/dev/null

    cp ${PWD}/consortium/crypto-config/peerOrganizations/insurance/peers/peer0.insurance/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/insurance/peers/peer0.insurance/tls/ca.crt
    cp ${PWD}/consortium/crypto-config/peerOrganizations/insurance/peers/peer0.insurance/tls/signcerts/* ${PWD}/consortium/crypto-config/peerOrganizations/insurance/peers/peer0.insurance/tls/server.crt
    cp ${PWD}/consortium/crypto-config/peerOrganizations/insurance/peers/peer0.insurance/tls/keystore/* ${PWD}/consortium/crypto-config/peerOrganizations/insurance/peers/peer0.insurance/tls/server.key


    mkdir -p ${PWD}/consortium/crypto-config/peerOrganizations/insurance/msp/tlscacerts
    cp ${PWD}/consortium/crypto-config/peerOrganizations/insurance/peers/peer0.insurance/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/insurance/msp/tlscacerts/ca.crt

    mkdir -p ${PWD}/consortium/crypto-config/peerOrganizations/insurance/tlsca
    cp ${PWD}/consortium/crypto-config/peerOrganizations/insurance/peers/peer0.insurance/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/insurance/tlsca/tlsca.insurance-cert.pem

    mkdir -p ${PWD}/consortium/crypto-config/peerOrganizations/insurance/ca
    cp ${PWD}/consortium/crypto-config/peerOrganizations/insurance/peers/peer0.insurance/msp/cacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/insurance/ca/ca.insurance-cert.pem
    cp ${PWD}/consortium/crypto-config/peerOrganizations/insurance/msp/keystore/* ${PWD}/consortium/crypto-config/peerOrganizations/insurance/ca/

    # Peer 1

    mkdir -p /consortium/crypto-config/peerOrganizations/insurance/peers/peer1.insurance

    infoln "Generating the peer1 msp"
    set -x
    fabric-ca-client enroll -u https://peer1:peer1pw@localhost:8054 --caname ca.insurance -M ${PWD}/consortium/crypto-config/peerOrganizations/insurance/peers/peer1.insurance/msp --csr.hosts peer1.insurance --tls.certfiles ${PWD}/consortium/fabric-ca/insurance/tls-cert.pem
    { set +x; } 2>/dev/null

    cp ${PWD}/consortium/crypto-config/peerOrganizations/insurance/msp/config.yaml ${PWD}/consortium/crypto-config/peerOrganizations/insurance/peers/peer1.insurance/msp/config.yaml

    infoln "Generating the peer1-tls certificates"
    set -x
    fabric-ca-client enroll -u https://peer1:peer1pw@localhost:8054 --caname ca.insurance -M ${PWD}/consortium/crypto-config/peerOrganizations/insurance/peers/peer1.insurance/tls --enrollment.profile tls --csr.hosts peer1.insurance --csr.hosts localhost --tls.certfiles ${PWD}/consortium/fabric-ca/insurance/tls-cert.pem
    { set +x; } 2>/dev/null

    cp ${PWD}/consortium/crypto-config/peerOrganizations/insurance/peers/peer1.insurance/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/insurance/peers/peer1.insurance/tls/ca.crt
    cp ${PWD}/consortium/crypto-config/peerOrganizations/insurance/peers/peer1.insurance/tls/signcerts/* ${PWD}/consortium/crypto-config/peerOrganizations/insurance/peers/peer1.insurance/tls/server.crt
    cp ${PWD}/consortium/crypto-config/peerOrganizations/insurance/peers/peer1.insurance/tls/keystore/* ${PWD}/consortium/crypto-config/peerOrganizations/insurance/peers/peer1.insurance/tls/server.key


    infoln "Generating the user msp"
    set -x
    fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca.insurance -M ${PWD}/consortium/crypto-config/peerOrganizations/insurance/users/User1@insurance/msp --tls.certfiles ${PWD}/consortium/fabric-ca/insurance/tls-cert.pem
    { set +x; } 2>/dev/null

    cp ${PWD}/consortium/crypto-config/peerOrganizations/insurance/msp/config.yaml ${PWD}/consortium/crypto-config/peerOrganizations/insurance/users/User1@insurance/msp/config.yaml

    infoln "Generating the org admin msp"
    set -x
    fabric-ca-client enroll -u https://org1admin:org1adminpw@localhost:8054 --caname ca.insurance -M ${PWD}/consortium/crypto-config/peerOrganizations/insurance/users/Admin@insurance/msp --tls.certfiles ${PWD}/consortium/fabric-ca/insurance/tls-cert.pem
    { set +x; } 2>/dev/null

    cp ${PWD}/consortium/crypto-config/peerOrganizations/insurance/msp/config.yaml ${PWD}/consortium/crypto-config/peerOrganizations/insurance/users/Admin@insurance/msp/config.yaml
}

function generateOrderer() {
  infoln "Enrolling the CA orderer"
  mkdir -p consortium/crypto-config/ordererOrganizations/example.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/consortium/crypto-config/ordererOrganizations/example.com

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles ${PWD}/consortium/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/consortium/crypto-config/ordererOrganizations/example.com/msp/config.yaml

  infoln "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/consortium/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/consortium/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p consortium/crypto-config/ordererOrganizations/example.com/orderers
  mkdir -p consortium/crypto-config/ordererOrganizations/example.com/orderers/example.com

  mkdir -p consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com

  infoln "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles ${PWD}/consortium/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/msp/config.yaml ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/config.yaml

  infoln "Generating the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls --enrollment.profile tls --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles ${PWD}/consortium/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt
  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/signcerts/* ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/keystore/* ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key

  mkdir -p ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts
  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  mkdir -p ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/msp/tlscacerts
  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  infoln "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp --tls.certfiles ${PWD}/consortium/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/msp/config.yaml ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/config.yaml
}

generateInsuranceCertificate
