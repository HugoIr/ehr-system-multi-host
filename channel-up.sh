configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/hospital-channel.tx -channelID hospital-channel

sudo docker exec cli peer channel create -o orderer.example.com:7050 -c hospital-channel -f ./channel-artifacts/hospital-channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
sleep 5

sudo docker exec cli peer channel join -b ./channel-artifacts/hospital-channel.block

sudo docker exec -e CORE_PEER_TLS_ENABLED=true -e CORE_PEER_LOCALMSPID="HospitalMSP" -e CORE_PEER_ADDRESS=34.128.89.87:8051 -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/consortium/crypto-config/peerOrganizations/hospital/users/Admin@hospital/msp -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital/tls/ca.crt cli peer channel join -b ./channel-artifacts/hospital-channel.block

sudo docker exec -e CORE_PEER_TLS_ENABLED=true -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/consortium/crypto-config/peerOrganizations/insurance/users/Admin@insurance/msp -e CORE_PEER_ADDRESS=34.101.138.254:9051 -e CORE_PEER_LOCALMSPID="InsuranceMSP" -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/consortium/crypto-config/peerOrganizations/insurance/peers/peer0.insurance/tls/ca.crt cli peer channel join -b ./channel-artifacts/hospital-channel.block

sudo docker exec cli peer channel update -o 34.101.204.172:7050 -c hospital-channel -f ./channel-artifacts/hospital-channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

sudo docker exec -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/consortium/crypto-config/peerOrganizations/insurance/users/Admin@insurance/msp -e CORE_PEER_ADDRESS=peer0.insurance:9051 -e CORE_PEER_LOCALMSPID="InsuranceMSP" -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/consortium/crypto-config/peerOrganizations/insurance/peers/peer0.insurance/tls/ca.crt cli peer channel update -o orderer.example.com:7050 -c hospital-channel -f ./channel-artifacts/hospital-channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

#approvemyorg - peer1.hos
sudo docker exec -e CORE_PEER_TLS_ENABLED=true -e CORE_PEER_LOCALMSPID="HospitalMSP" -e CORE_PEER_ADDRESS=34.128.89.87:8051 -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/consortium/crypto-config/peerOrganizations/hospital/users/Admin@hospital/msp -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital/tls/ca.crt cli peer lifecycle chaincode approveformyorg -o 34.101.204.172:7050 --signature-policy 'OR('\''HospitalMSP.member'\'', '\''InsuranceMSP.member'\'')' --ordererTLSHostnameOverride orderer.example.com --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --channelID hospital-channel --name fab-healthcare --version 1.0 --package-id fab-healthcare_1.0:6176370336e6263dec6d641f477ee497cc70344989f7e0a438871c0f17a9b5d1 --peerAddresses 34.101.204.172:7051 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem  --sequence 1 --init-required

sudo docker exec -e CORE_PEER_TLS_ENABLED=true -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/consortium/crypto-config/peerOrganizations/insurance/users/Admin@insurance/msp -e CORE_PEER_ADDRESS=34.101.138.254:9051 -e CORE_PEER_LOCALMSPID="InsuranceMSP" -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/consortium/crypto-config/peerOrganizations/insurance/peers/peer0.insurance/tls/ca.crt cli peer lifecycle chaincode approveformyorg -o 34.101.204.172:7050 --signature-policy 'OR('\''HospitalMSP.member'\'', '\''InsuranceMSP.member'\'')' --ordererTLSHostnameOverride orderer.example.com --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --channelID hospital-channel --name fab-healthcare --version 1.0 --package-id fab-healthcare_1.0:6176370336e6263dec6d641f477ee497cc70344989f7e0a438871c0f17a9b5d1 --sequence 1 --init-required

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_ORG1_CA=${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer0.hospital/tls/ca.crt
export PEER1_ORG1_CA=${PWD}/consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/consortium/crypto-config/peerOrganizations/insurance/peers/peer0.insurance/tls/ca.crt
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/tls-34.101.204.172-9054-ca-orderer.pem
export CORE_PEER_MSPCONFIGPATH=${PWD}/consortium/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp

    export CORE_PEER_LOCALMSPID="HospitalMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/consortium/crypto-config/peerOrganizations/hospital/users/Admin@hospital/msp
    export CORE_PEER_ADDRESS=peer1.hospital:8051

    sudo docker exec -e CORE_PEER_ADDRESS=34.128.89.87:8051 -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital/tls/ca.crt cli peer channel join -b mychannel.block

    openssl x509 -in consortium/fabric-ca/hospital/tls-cert.pem -text -noout
    

    openssl x509 -in consortium/crypto-config/peerOrganizations/hospital/peers/peer1.hospital/tls/server.crt -text -noout
    outputnya X509v3 Subject Alternative Name: 
                DNS:peer1.hospital, DNS:localhost


    sudo docker exec cli peer chaincode instantiate -o 34.101.204.172:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C hospital-channel -n fab-healthcare -v 1 -c '{"Args":[]}' -P "OR ('HospitalMSP.peer','InsuranceMSP.peer')"

    sudo docker exec cli peer chaincode query -n fab-healthcare -C hospital-channel -c '{"Args":[]}'