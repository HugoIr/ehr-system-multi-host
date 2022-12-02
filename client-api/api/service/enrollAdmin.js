//module.js
const FabricCAServices = require('fabric-ca-client');
const { Wallets } = require('fabric-network');
const fs = require('fs');
const path = require('path');

const enrollAdmin = async (enrollId, enrollSecret, organizationType) => {
    try {
        // const organizationType = "insurance";
        // load the network configuration
        console.log('DIRNAME ', __dirname);
        // const ccpPath = path.resolve(__dirname, '..', 'test-network', 'organizations', 'peerOrganizations', 'org1.example.com', 'connection-org1.json');
        const ccpPath = path.resolve(__dirname, '..', '..', '..',   'consortium', 'crypto-config', 'peerOrganizations', organizationType, `connection-${organizationType}.json`);
        console.log('ccpPath ', ccpPath);
        console.log("org caps ", organizationType.capitalize())
        const ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));

        // Create a new CA client for interacting with the CA.
        const caInfo = ccp.certificateAuthorities[`ca.${organizationType}`];
        const caTLSCACerts = caInfo.tlsCACerts.pem;
        const ca = new FabricCAServices(caInfo.url, { trustedRoots: caTLSCACerts, verify: false }, caInfo.caName);

        // Create a new file system based wallet for managing identities.
        const walletPath = path.join(process.cwd(), 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);

        // Check to see if we've already enrolled the admin user.
        const identity = await wallet.get(enrollId);
        if (identity) {
            throw 'An identity for the admin already exists in the wallet'
        }
        console.log("Identity, ", identity)
        
        // Enroll the admin user, and import the new identity into the wallet.
        const enrollment = await ca.enroll ({ 
            enrollmentID: 'admin', 
            enrollmentSecret: enrollSecret 
        });
        console.log("enrollment, ", enrollment)
        const x509Identity = {
            credentials: {
                certificate: enrollment.certificate,
                privateKey: enrollment.key.toBytes(),
            },
            mspId: `${organizationType.capitalize()}MSP`,
            type: 'X.509',
        };
        console.log("x509Identity, ", x509Identity)
        await wallet.put(enrollId, x509Identity);
        console.log('Successfully enrolled admin user "admin" and imported it into the wallet');

    } catch (error) {
        console.error(`Failed to enroll admin user "admin": ${error}`);
        throw error.toString()
    }
}

module.exports = {enrollAdmin};
