//module.js
const FabricCAServices = require('fabric-ca-client');
const { Wallets } = require('fabric-network');
const fs = require('fs');
const path = require('path');

const registerUser = async (email, organizationType) => {
    try {
        // load the network configuration
        const ccpPath = path.resolve(__dirname, '..', '..', '..',   'consortium', 'crypto-config', 'peerOrganizations', 'hospital', 'connection-hospital.json');
        const ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));

        // Create a new CA client for interacting with the CA.
        const caURL = ccp.certificateAuthorities['ca.hospital'].url;
        const ca = new FabricCAServices(caURL);

        const ccpPath2 = path.resolve(__dirname, '..', '..', '..',   'consortium', 'crypto-config', 'peerOrganizations', 'insurance', 'connection-insurance.json');
        const ccp2 = JSON.parse(fs.readFileSync(ccpPath2, 'utf8'));

        // Create a new CA client for interacting with the CA.
        const caURL2 = ccp2.certificateAuthorities['ca.insurance'].url;
        const ca2 = new FabricCAServices(caURL2);

        // Create a new file system based wallet for managing identities.
        const walletPath = path.join(process.cwd(), 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);
        

        // Check to see if we've already enrolled the user.
        const userIdentity = await wallet.get('appUserIns');
        if (userIdentity) {
            console.log('An identity for the user "appUserIns" already exists in the wallet');
            return;
        }

        // Check to see if we've already enrolled the admin user.
        const adminIdentity = await wallet.get('admin2');
        if (!adminIdentity) {
            console.log('An identity for the admin user "admin" does not exist in the wallet');
            console.log('Run the enrollAdmin.js application before retrying');
            return;
        }

        // build a user object for authenticating with the CA
        const provider = wallet.getProviderRegistry().getProvider(adminIdentity.type);
        const adminUser = await provider.getUserContext(adminIdentity, 'admin2');

        // Register the user, enroll the user, and import the new identity into the wallet.
        const secret = await ca2.register({
            enrollmentID: 'appUserIns',
            role: 'client'
        }, adminUser);
        const enrollment = await ca2.enroll({
            enrollmentID: 'appUserIns',
            enrollmentSecret: secret
        });
        const x509Identity = {
            credentials: {
                certificate: enrollment.certificate,
                privateKey: enrollment.key.toBytes(),
            },
            mspId: 'InsuranceMSP',
            type: 'X.509',
        };
        await wallet.put('appUserIns', x509Identity);
        console.log('Successfully registered and enrolled admin user "appUserIns" and imported it into the wallet');

    } catch (error) {
        console.error(`Failed to register user "appUserIns": ${error}`);
        
    }
}

module.exports = {registerUser};
