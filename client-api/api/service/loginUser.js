//module.js
const FabricCAServices = require('fabric-ca-client');
const { Wallets } = require('fabric-network');
const fs = require('fs');
const path = require('path');
const { getAdminIdentity, getOrganizationTypeFromMSP } = require('../utils/helper');

const loginUser = async (email) => {
    try {
        // load the network configuration
        const ccpPath = path.resolve(__dirname, '..', '..', '..',   'consortium', 'crypto-config', 'peerOrganizations', 'hospital', 'connection-hospital.json');
        
        // ccp = connection profile
        const ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));

        // Create a new file system based wallet for managing identities.
        const walletPath = path.join(process.cwd(), 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);

        // Check to see if we've already enrolled the user.
        const identity = await wallet.get(email);
        if (!identity) {
            throw "User does not exist"
        }
        console.log(`identity: ${identity.mspId}`);
        console.log("getOrganizationTypeFromMSP(identity.mspId) ", getOrganizationTypeFromMSP(identity.mspId))
        return {
            'email': email,
            'organizationType': getOrganizationTypeFromMSP(identity.mspId)
        }
    } catch (error) {
        console.error(`Failed to register user email: ${error}`);
        throw error.toString()
    }
}

module.exports = {loginUser};
