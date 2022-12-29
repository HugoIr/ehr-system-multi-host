#!/bin/bash

. scripts/utils.sh
export PATH=${PWD}/bin:$PATH

function generateOrderer() {
  infoln "Enrolling the CA orderer"
  mkdir -p consortium/crypto-config/ordererOrganizations/example.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/consortium/crypto-config/ordererOrganizations/example.com

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@34.101.204.172:9054 --caname ca-orderer --tls.certfiles ${PWD}/consortium/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/34-101-204-172-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/34-101-204-172-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/34-101-204-172-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/34-101-204-172-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/consortium/crypto-config/ordererOrganizations/example.com/msp/config.yaml

  infoln "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/consortium/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/consortium/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null


  infoln "Registering orderer 2"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer2 --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/consortium/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null


  infoln "Registering orderer 3"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer3 --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/consortium/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null
  # infoln "Registering the orderer 2 admin"
  # set -x
  # fabric-ca-client register --caname ca-orderer --id.name ordererAdmin2 --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/consortium/fabric-ca/ordererOrg/tls-cert.pem
  # { set +x; } 2>/dev/null

  mkdir -p consortium/crypto-config/ordererOrganizations/example.com/orderers
  mkdir -p consortium/crypto-config/ordererOrganizations/example.com/orderers/example.com

  mkdir -p consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com
  mkdir -p consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com
  mkdir -p consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com

  infoln "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@34.101.204.172:9054 --caname ca-orderer -M ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp --csr.hosts orderer.example.com --csr.hosts 34.101.204.172 --tls.certfiles ${PWD}/consortium/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/msp/config.yaml ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/config.yaml

  infoln "Generating the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@34.101.204.172:9054 --caname ca-orderer -M ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls --enrollment.profile tls --csr.hosts orderer.example.com --csr.hosts 34.101.204.172 --tls.certfiles ${PWD}/consortium/fabric-ca/ordererOrg/tls-cert.pem
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
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@34.101.204.172:9054 --caname ca-orderer -M ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp --tls.certfiles ${PWD}/consortium/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null


  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/msp/config.yaml ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/config.yaml



  infoln "Generating the orderer 2 msp"
  set -x
  fabric-ca-client enroll -u https://orderer2:ordererpw@34.101.204.172:9054 --caname ca-orderer -M ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/msp --csr.hosts orderer2.example.com --csr.hosts 34.128.89.87 --tls.certfiles ${PWD}/consortium/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/msp/config.yaml ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/msp/config.yaml

  infoln "Generating the orderer-tls 2 certificates"
  set -x
  fabric-ca-client enroll -u https://orderer2:ordererpw@34.101.204.172:9054 --caname ca-orderer -M ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls --enrollment.profile tls  --csr.hosts orderer2.example.com --csr.hosts 34.128.89.87 --tls.certfiles ${PWD}/consortium/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/tlscacerts/* ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/ca.crt
  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/signcerts/* ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/server.crt
  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/keystore/* ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/server.key

  mkdir -p ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/msp/tlscacerts
  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/tlscacerts/* ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  mkdir -p ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/msp/tlscacerts
  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/tlscacerts/* ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem


  infoln "Generating the orderer 3 msp"
  set -x
  fabric-ca-client enroll -u https://orderer3:ordererpw@34.101.204.172:9054 --caname ca-orderer -M ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/msp --csr.hosts orderer3.example.com --csr.hosts 34.101.138.254 --tls.certfiles ${PWD}/consortium/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/msp/config.yaml ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/msp/config.yaml

  infoln "Generating the orderer-tls 3 certificates"
  set -x
  fabric-ca-client enroll -u https://orderer3:ordererpw@34.101.204.172:9054 --caname ca-orderer -M ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls --enrollment.profile tls  --csr.hosts orderer3.example.com --csr.hosts 34.101.138.254 --tls.certfiles ${PWD}/consortium/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/tlscacerts/* ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/ca.crt
  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/signcerts/* ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/server.crt
  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/keystore/* ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/server.key

  mkdir -p ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/msp/tlscacerts
  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/tlscacerts/* ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  mkdir -p ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/msp/tlscacerts
  cp ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/tlscacerts/* ${PWD}/consortium/crypto-config/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem


}



generateOrderer
