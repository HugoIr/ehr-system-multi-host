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
        console.log(`Wallet path: ${walletPath}`);

        // Check to see if we've already enrolled the user.
        const identity = await wallet.get(user);
        if (!identity) {
            throw "User does not exist"
        }
        console.log(`identity: ${identity.mspId}`);
        console.log(`identity: ${ccp}`);
        // Create a new gateway for connecting to our peer node.
        const gateway = new Gateway();
        await gateway.connect(ccp, { wallet, identity: identity, discovery: { enabled: true, asLocalhost: true } });

        // Get the network (channel) our contract is deployed to.
        const network = await gateway.getNetwork('hospital-channel');

        // Get the contract from the network.
        // defined in CC_NAME network-setup.sh
        const contract = network.getContract('fab-healthcare');

        // Evaluate the specified transaction.
        const result = await contract.evaluateTransaction('queryEhr', id);
        console.log(`Transaction has been evaluated, result is: ${result.toString()}`);
        // Disconnect from the gateway.

        // console.log("RESULT ", typeof result)
        // console.log("RESULT ", JSON.parse(result)['insurance'])


        // const caURL = ccp.certificateAuthorities[`ca.hospital`].url;
        // const ca = new FabricCAServices(caURL);
        // const adminIdentity = await wallet.get('admin');
        // const provider = wallet.getProviderRegistry().getProvider(adminIdentity.type);
        // const adminUser = await provider.getUserContext(adminIdentity, 'admin');
        // let affiliationService = ca.newAffiliationService();
        // let registeredAffiliations = await affiliationService.getAll(adminUser);
        // // let adminUserObj = await client.setUserContext({
        // //     username: "admin",
        // //     password: "adminpw"
        // //   });
        
        // console.log("AffiliationService.getAll", registeredAffiliations.result)
        // // console.log("AffiliationService.getAll aff", registeredAffiliations.result.affiliations[0].affiliations)
        // // console.log("AffiliationService.getAll aff", registeredAffiliations.result.affiliations[1].affiliations)
        // // console.log("AffiliationService.getAll aff", registeredAffiliations.result.affiliations[2].affiliations)

        // console.log("adminUser.getAffiliation()" , adminUser.getMspid())
        // console.log("registeredd  ", !registeredAffiliations.result.affiliations.map(x => x.name == adminUser.getMspid()))

        // // if (!registeredAffiliations.result.affiliations.some(x => x.name == 'insurance')) {
        // //     let affiliation = "org2" + '.department3';
        // //     console.log("AFFILIATION ", affiliation)
        // //     await affiliationService.create({
        // //       name: affiliation,
        // //       force: true
        // //     }, adminUser);
        // // }
        // console.log("after AffiliationService.getAll", registeredAffiliations.result)
        // console.log("after AffiliationService.getAll aff", registeredAffiliations.result.affiliations[0].affiliations)

        await gateway.disconnect();
        
        return getEhrParser(result);
        
    } catch (error) {
        console.error(`Failed to evaluate transaction: ${error}`);
        throw error.toString();
    }
}

module.exports = {getEhrById};