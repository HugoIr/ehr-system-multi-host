Start Docker First

cd src/
./startFabric.sh

clean src/wallet/ dir if neccessary
node enrollAdmin.js && node registerUser.js
node query.js

darimana hyperledger tau nama contract yang kita buat?
pada startFabric.sh, ada command sbg berikut
./network.sh deployCC -ccn ehr -ccv 1 -cci initLedger -ccl ${CC_SRC_LANGUAGE} -ccp ${CC_SRC_PATH}

CC_SRC_PATH disini adalah alamat chaincode kita.


TUTORIAL CARA BUAT THIS APP FROM SCRATCH

init folder docker, consortium, ..

add docker-compose-ca.yaml di folder docker dan isi dengan basic setup ca for docker compose
run those file: docker compose -f ./docker/docker-compose-ca.yaml up -d


take a look at generate-certificate.sh code
ada baris yang menjalankan fabric-ca-client enroll
DARIMANA DATANGNYA KAH? pdhl kan kita ga define fungsi tsb
asalnya dari folder bin di root, di dalamnya ada file fabric-ca-client yang merupakan executable program (?)

lalu, gimana pakai fabric-ca-client pada generate-certificate.sh?
dengan mendefine lokasi bin, export PATH=${PWD}/bin:$PATH
 

docker compose -f docker/docker-compose-ca.yaml up -d
./generate-certificate.sh




NOTES TERBARUU!!!
DONT FORGET TO CLEAN UP USING ./network-setup.sh down
^ Tujuannya supaya sampah2 di dockernya di clean up

STEPP DARI AWALL BANGET
./network-setup.sh down
docker compose -f docker/docker-compose-ca.yaml up -d
./generate-certificate.sh
./network-setup.sh up 
./network-setup.sh createChannel
./network-setup.sh deployCC
./consortium/ccp-generate.sh


docker compose -f docker/docker-compose-net-host1.yaml up -d
