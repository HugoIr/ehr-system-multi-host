#!/bin/bash

source scripts/utils.sh

. scripts/deployCC.sh

infoln "Install chaincode on peer0.insurance..."
installChaincode 2


# ## check whether the chaincode definition is ready to be committed
# ## expect hospital to have approved and org2 not to
# checkCommitReadiness 1 "\"HospitalMSP\": true" "\"InsuranceMSP\": false"
# checkCommitReadiness 2 "\"HospitalMSP\": true" "\"InsuranceMSP\": false"

# ## now approve also for insurance
# approveForMyOrg 2

# ## check whether the chaincode definition is ready to be committed
# ## expect them both to have approved
# checkCommitReadiness 1 "\"HospitalMSP\": true" "\"InsuranceMSP\": true"
# checkCommitReadiness 2 "\"HospitalMSP\": true" "\"InsuranceMSP\": true"

# ## now that we know for sure both orgs have approved, commit the definition
# commitChaincodeDefinition 1 2 3

# ## query on both orgs to see that the definition committed successfully
# queryCommitted 1
# queryCommitted 2

# ## Invoke the chaincode - this does require that the chaincode have the 'initLedger'
# ## method defined
# if [ "$CC_INIT_FCN" = "NA" ]; then
#   infoln "Chaincode initialization is not required"
# else
#   chaincodeInvokeInit 1 2
# fi

# exit 0
