const { Gateway, Wallets } = require('fabric-network');
const fs = require('fs');
const path = require('path');
const { randomUUID } = require('crypto'); // Added in: node v14.17.0

const updateEhr = async (
    user,
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
        
        // console.log("MEDICAL HIsto ", medicalHistory)
        // console.log("MEDICAL HIsto stringify ", JSON.stringify(medicalHistory))
        // Submit the specified transaction.
        // const result = await contract.evaluateTransaction('queryAllEhrs');
        await contract.submitTransaction('updateEhr',
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
        // await contract.submitTransaction('updateEhr', 'EHR3', 'Doni', '29', 'Male', 'Indonesia', 'healthy');
        console.log('Transaction has been submitted');
        
        // Disconnect from the gateway.
        await gateway.disconnect();
        return 'Transaction has been submitted'

    } catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        throw error.toString()
        // process.exit(1);
    }
}

module.exports = {updateEhr};