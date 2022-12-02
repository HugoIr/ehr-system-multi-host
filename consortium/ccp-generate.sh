#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}
function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        consortium/ccp-template.json
}

function yaml_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        consortium/ccp-template.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

function json_ccp_2peer {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${P1PORT}/$6/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        consortium/ccp-template-2peer.json
}

function yaml_ccp_2peer {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${P1PORT}/$6/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        consortium/ccp-template-2peer.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

ORG="hospital"
P0PORT=7051
P1PORT=8051
CAPORT=7054
PEERPEM=consortium/crypto-config/peerOrganizations/hospital/tlsca/tlsca.hospital-cert.pem
CAPEM=consortium/crypto-config/peerOrganizations/hospital/ca/ca.hospital-cert.pem

echo "$(json_ccp_2peer $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $P1PORT)" > consortium/crypto-config/peerOrganizations/hospital/connection-hospital.json
echo "$(yaml_ccp_2peer $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $P1PORT)" > consortium/crypto-config/peerOrganizations/hospital/connection-hospital.yaml

ORG="insurance"
P0PORT=9051
CAPORT=8054
PEERPEM=consortium/crypto-config/peerOrganizations/insurance/tlsca/tlsca.insurance-cert.pem
CAPEM=consortium/crypto-config/peerOrganizations/insurance/ca/ca.insurance-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > consortium/crypto-config/peerOrganizations/insurance/connection-insurance.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > consortium/crypto-config/peerOrganizations/insurance/connection-insurance.yaml
