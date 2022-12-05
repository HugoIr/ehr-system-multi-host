const { Gateway, Wallets } = require('fabric-network');
const fs = require('fs');
const path = require('path');
const { randomUUID } = require('crypto'); // Added in: node v14.17.0

const createEhr = async (
    user,
    name,
    dateOfBirth,
    address,
    phoneNumber,
    gender, 
    nationality,
    bloodType,
    height,
    weight,
    pulseRate,
    bloodPressure,
    respiratoryRate,
    medicalHistory,
    diagnose,
    insuranceName,
    ) => {
    try {
        // load the network configuration
        const ccpPath = path.resolve(__dirname, '..', '..', '..',   'consortium', 'crypto-config', 'peerOrganizations', 'hospital', 'connection-hospital.json');
        let ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));

        // Create a new file system based wallet for managing identities.
        const walletPath = path.join(process.cwd(), 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);

        // Check to see if we've already enrolled the user.
        const identity = await wallet.get(user);
        if (!identity) {
            throw "User does not exist"
        }

        // Create a new gateway for connecting to our peer node.
        const gateway = new Gateway();
        await gateway.connect(ccp, { wallet, identity: identity, discovery: { enabled: true, asLocalhost: false } });

        // Get the network (channel) our contract is deployed to.
        const network = await gateway.getNetwork('hospital-channel');

        // Get the contract from the network.
        // defined in CC_NAME network-setup.sh
        const contract = network.getContract('fab-healthcare');
        const ehrId = randomUUID();
        await contract.submitTransaction('createEhr',
            ehrId,
            name,
            dateOfBirth,
            address,
            phoneNumber,
            gender, 
            nationality,
            bloodType,
            height,
            weight,
            pulseRate,
            bloodPressure,
            respiratoryRate,
            JSON.stringify(medicalHistory), 
            JSON.stringify(diagnose), 
            insuranceName,
            );
        // await contract.submitTransaction('createEhr', 'EHR3', 'Doni', '29', 'Male', 'Indonesia', 'healthy');
        console.log('Transaction has been submitted');
        
        // Disconnect from the gateway.
        await gateway.disconnect();
        return ehrId

    } catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        throw error.toString()
        // process.exit(1);
    }
}

module.exports = {createEhr};