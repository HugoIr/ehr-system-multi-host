#!/bin/bash

. scripts/utils.sh
export PATH=${PWD}/bin:$PATH

function generateHospitalCertificate() {
    echo
    echo "Enroll the admin"
    echo
    mkdir -p consortium/crypto-config/peerOrganizations/hospital/
    export FABRIC_CA_CLIENT_HOME=${PWD}/consortium/crypto-config/peerOrganizations/hospital/

    fabric-ca-client enroll -u https://admin:adminpw@34.101.204.172:7054 --caname ca.hospital --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem

    echo 'NodeOUs:
    Enable: true
    ClientOUIdentifier:
        Certificate: cacerts/34-101-204-172-7054-ca-hospital.pem
        OrganizationalUnitIdentifier: client
    PeerOUIdentifier:
        Certificate: cacerts/34-101-204-172-7054-ca-hospital.pem
        OrganizationalUnitIdentifier: peer
    AdminOUIdentifier:
        Certificate: cacerts/34-101-204-172-7054-ca-hospital.pem
        OrganizationalUnitIdentifier: admin
    OrdererOUIdentifier:
        Certificate: cacerts/34-101-204-172-7054-ca-hospital.pem
        OrganizationalUnitIdentifier: orderer' >${PWD}/consortium/crypto-config/peerOrganizations/hospital/msp/config.yaml

    infoln "Registering peer0"
    set -x
    fabric-ca-client register --caname ca.hospital --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem
    { set +x; } 2>/dev/null

    infoln "Registering peer1"
    set -x
    fabric-ca-client register --caname ca.hospital --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem
    { set +x; } 2>/dev/null

    infoln "Registering user"
    set -x
    fabric-ca-client register --caname ca.hospital --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem
    { set +x; } 2>/dev/null

    infoln "Registering the org admin"
    set -x
    fabric-ca-client register --caname ca.hospital --id.name org1admin --id.secret org1adminpw --id.type admin --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem
    { set +x; } 2>/dev/null

    mkdir -p consortium/crypto-config/peerOrganizations/hospital/peers

    mkdir -p consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital

    # Peer 0
    infoln "Generating the peer0 msp"
    set -x
    fabric-ca-client enroll -u https://peer0:peer0pw@34.101.204.172:7054 --caname ca.hospital -M ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/msp --csr.hosts peer0.hospital --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem
    { set +x; } 2>/dev/null

    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/msp/config.yaml ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/msp/config.yaml

    infoln "Generating the peer0-tls certificates"
    set -x
    fabric-ca-client enroll -u https://peer0:peer0pw@34.101.204.172:7054 --caname ca.hospital -M ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls --enrollment.profile tls --csr.hosts peer0.hospital --csr.hosts localhost --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem
    { set +x; } 2>/dev/null

    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls/ca.crt
    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls/signcerts/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls/server.crt
    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls/keystore/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls/server.key


    mkdir -p ${PWD}/consortium/crypto-config/peerOrganizations/hospital/msp/tlscacerts
    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/msp/tlscacerts/ca.crt

    mkdir -p ${PWD}/consortium/crypto-config/peerOrganizations/hospital/tlsca
    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/tlsca/tlsca.hospital-cert.pem

    mkdir -p ${PWD}/consortium/crypto-config/peerOrganizations/hospital/ca
    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/msp/cacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/ca/ca.hospital-cert.pem
    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/msp/keystore/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/ca/

    # Peer 1

    mkdir -p /consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital

    infoln "Generating the peer1 msp"
    set -x
    fabric-ca-client enroll -u https://peer1:peer1pw@34.101.204.172:7054 --caname ca.hospital -M ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital/msp --csr.hosts peer1.hospital --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem
    { set +x; } 2>/dev/null

    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/msp/config.yaml ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital/msp/config.yaml

    infoln "Generating the peer1-tls certificates"
    set -x
    fabric-ca-client enroll -u https://peer1:peer1pw@34.101.204.172:7054 --caname ca.hospital -M ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital/tls --enrollment.profile tls --csr.hosts peer1.hospital --csr.hosts localhost --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem
    { set +x; } 2>/dev/null

    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital/tls/tlscacerts/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital/tls/ca.crt
    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital/tls/signcerts/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital/tls/server.crt
    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital/tls/keystore/* ${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital/tls/server.key


    infoln "Generating the user msp"
    set -x
    fabric-ca-client enroll -u https://user1:user1pw@34.101.204.172:7054 --caname ca.hospital -M ${PWD}/consortium/crypto-config/peerOrganizations/hospital/users/User1@hospital/msp --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem
    { set +x; } 2>/dev/null

    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/msp/config.yaml ${PWD}/consortium/crypto-config/peerOrganizations/hospital/users/User1@hospital/msp/config.yaml

    infoln "Generating the org admin msp"
    set -x
    fabric-ca-client enroll -u https://org1admin:org1adminpw@34.101.204.172:7054 --caname ca.hospital -M ${PWD}/consortium/crypto-config/peerOrganizations/hospital/users/Admin@hospital/msp --tls.certfiles ${PWD}/consortium/fabric-ca/hospital/tls-cert.pem
    { set +x; } 2>/dev/null

    cp ${PWD}/consortium/crypto-config/peerOrganizations/hospital/msp/config.yaml ${PWD}/consortium/crypto-config/peerOrganizations/hospital/users/Admin@hospital/msp/config.yaml
}

generateHospitalCertificate
