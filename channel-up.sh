docker exec cli peer channel create -o orderer.example.com:7050 -c hospital-channel -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
sleep 5

docker exec cli peer channel join -b hospital-channel.block

docker exec -e CORE_PEER_ADDRESS=peer1.hospital.com:8051 -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/consortium/crypto-config/peerOrganizations/hospital.com/peers/peer1.hospital.com/tls/ca.crt cli peer channel join -b hospital-channel.block

docker exec -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/consortium/crypto-config/peerOrganizations/insurance/users/Admin@insurance/msp -e CORE_PEER_ADDRESS=peer0.insurance:9051 -e CORE_PEER_LOCALMSPID="InsuranceMSP" -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/consortium/crypto-config/peerOrganizations/insurance/peers/peer0.insurance/tls/ca.crt cli peer channel join -b hospital-channel.block

docker exec cli peer channel update -o orderer.example.com:7050 -c hospital-channel -f ./channel-artifacts/Org1MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

docker exec -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/consortium/crypto-config/peerOrganizations/insurance/users/Admin@insurance/msp -e CORE_PEER_ADDRESS=peer0.insurance:9051 -e CORE_PEER_LOCALMSPID="InsuranceMSP" -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/consortium/crypto-config/peerOrganizations/insurance/peers/peer0.insurance/tls/ca.crt cli peer channel update -o orderer.example.com:7050 -c hospital-channel -f ./channel-artifacts/InsuranceMSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/consortium/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem