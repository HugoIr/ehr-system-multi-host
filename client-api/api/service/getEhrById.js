const { Gateway, Wallets } = require('fabric-network');
const path = require('path');
const fs = require('fs');
const { AffiliationService } = require('fabric-ca-client');
const FabricCAServices = require('fabric-ca-client');
const { getEhrParser } = require('../utils/converter');


const getEhrById = async (id, user) => {
    try {
        // load the network configuration
        const ccpPath = path.resolve(__dirname, '..', '..', '..',   'consortium', 'crypto-config', 'peerOrganizations', 'hospital', 'connection-hospital.json');
        
        // ccp = connection profile
        const ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));

        // Create a new file system based wallet for managing identities.
        const walletPath = path.join(process.cwd(), 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);
        

        // Check to see if we've already enrolled the user.
        const identity = await wallet.get(user);
        if (!identity) {
            throw "User does not exist"
        }
        console.log(`identity: ${identity.mspId}`);
        console.log(`identity: ${ccp}`);
        // Create a new gateway for connecting to our peer node.
        const gateway = new Gateway();
        await gateway.connect(ccp, { wallet, identity: identity, discovery: { enabled: true, asLocalhost: false } });

        // Get the network (channel) our contract is deployed to.
        const network = await gateway.getNetwork('hospital-channel');

        // Get the contract from the network.
        // defined in CC_NAME network-setup.sh
        const contract = network.getContract('fab-healthcare');

        // Evaluate the specified transaction.
        const result = await contract.evaluateTransaction('queryEhr', id);
        console.log(`Transaction has been evaluated`);
       
        await gateway.disconnect();
        
        return getEhrParser(result);
        
    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error}`);
        throw error.toString();
    }
}

module.exports = {getEhrById};