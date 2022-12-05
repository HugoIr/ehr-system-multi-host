//module.js
const FabricCAServices = require('fabric-ca-client');
const { Wallets } = require('fabric-network');
const fs = require('fs');
const path = require('path');
const { getAdminIdentity } = require('../utils/helper');

const registerUser = async (email, organization, organizationType) => {
    try {
        // load the network configuration
        const ccpPath = path.resolve(__dirname, '..', '..', '..', 'consortium', 'crypto-config', 'peerOrganizations', organizationType, `connection-${organizationType}.json`);
        const ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));
        console.log("CCPT PAT ", ccpPath)

        // Create a new CA client for interacting with the CA.
        const caURL = ccp.certificateAuthorities[`ca.${organizationType}`].url;
        const ca = new FabricCAServices(caURL);

        // Create a new file system based wallet for managing identities.
        const walletPath = path.join(process.cwd(), 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);
        

        // Check to see if we've already enrolled the user.
        const userIdentity = await wallet.get(email);
        if (userIdentity) {
            throw 'An identity for the user email already exists in the wallet'
        }
        const adminId = getAdminIdentity(organizationType);
        // Check to see if we've already enrolled the admin user.
        const adminIdentity = await wallet.get(adminId);
        if (!adminIdentity) {
            throw "Admin network does not exist"
        }
        
        // build a user object for authenticating with the CA
        const provider = wallet.getProviderRegistry().getProvider(adminIdentity.type);
        
        const adminUser = await provider.getUserContext(adminIdentity, adminId);

        // Register the user, enroll the user, and import the new identity into the wallet.
        const secret = await ca.register({
            enrollmentID: email,
            role: "client",
            affiliation: organization,
        }, adminUser);

        console.log("SECRET of USER ", secret)

        const enrollment = await ca.enroll({
            enrollmentID: email,
            enrollmentSecret: secret
        });
        
        const x509Identity = {
            credentials: {
                certificate: enrollment.certificate,
                privateKey: enrollment.key.toBytes(),
            },
            mspId: `${organizationType.capitalize()}MSP`,
            type: 'X.509',
        };
        await wallet.put(email, x509Identity);
        console.log('Successfully registered and enrolled admin user email and imported it into the wallet');
        return secret;

    } catch (error) {
        console.error(`Failed to register user email: ${error}`);
        throw error.toString()
    }
}

module.exports = {registerUser};
