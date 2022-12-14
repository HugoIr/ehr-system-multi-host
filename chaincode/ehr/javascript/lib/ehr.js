/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Contract } = require('fabric-contract-api');

class Ehr extends Contract {

    async initLedger(ctx) {
        console.info('============= START : Initialize Ledger ===========');
        const ehrs = [
            
        ];

        for (let i = 0; i < ehrs.length; i++) {
            ehrs[i].docType = 'ehr';
            await ctx.stub.putState('EHR' + i, Buffer.from(JSON.stringify(ehrs[i])));
            console.info('Added <--> ', ehrs[i]);
        }
        console.info('============= END : Initialize Ledger ===========');
    }

    async queryEhrById(ctx, ehrId) {
        const ehrAsBytes = await ctx.stub.getState(ehrId); // get the ehr from chaincode state
        if (!ehrAsBytes || ehrAsBytes.length === 0) {
            throw new Error(`${ehrId} does not exist`);
        }
        const ehrResult = ehrAsBytes.toString()
        console.log("ehrAsBytes.toString() ", ehrAsBytes.toString());
        console.log("ctx.clientIdentity ", ctx.clientIdentity)
        console.log("ctx.clientIdentity.getAttributeValue()  ", ctx.clientIdentity.attrs['hf.Affiliation'])
        const mspId = ctx.clientIdentity.getMSPID()
        if (mspId == "HospitalMSP") {
            return ehrResult;
        } else if (mspId == "InsuranceMSP") {

            
            console.log("JSON.parse(ehrResult)['insuranceName'] ", JSON.parse(ehrResult)['insuranceName'])
            if (`insurance.${JSON.parse(ehrResult)['insuranceName']}` == ctx.clientIdentity.attrs['hf.Affiliation']) {
                return ehrResult;
            } else {
                throw new Error(`Not permitted to access ehr with id: ${ehrId}`);
            }
        } else {
            throw new Error(`Unknown MSPID: ${mspId}`);
        }
        
    }

    async createEhr(ctx, 
            id,
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
            

        ) {
        console.info('============= START : Create Ehr ===========');

        console.log("ctx.clientIdentity ", ctx.clientIdentity)
        const mspId = ctx.clientIdentity.getMSPID()
        if (mspId == "HospitalMSP") {

        const ehr = {
            id,
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
            
        };
        console.log("ERH smart contract " , ehr)
        await ctx.stub.putState(id, Buffer.from(JSON.stringify(ehr)));
        console.info('============= END : Create Ehr ===========');

        } else {
            throw Error(`Only Hospital Admin permitted to Create EHR`)
        }
    }

    async updateEhr(ctx, 
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
        

    ) {
    console.info('============= START : Update Ehr ===========');

    console.log("ctx.clientIdentity ", ctx.clientIdentity)
    const mspId = ctx.clientIdentity.getMSPID()
    
    if (mspId == "HospitalMSP") {
        const ehrAsBytes = await ctx.stub.getState(ehrId); // get the ehr from chaincode state
        if (!ehrAsBytes || ehrAsBytes.length === 0) {
            throw new Error(`${ehrId} does not exist`);
        }
        const ehr = JSON.parse(ehrAsBytes.toString());

        if (name != undefined) {
            ehr.name = name;
        }    
        if (dateOfBirth != undefined) {
            ehr.dateOfBirth = dateOfBirth;
        }
        if (address != undefined) {
            ehr.address = address;
        }
        if (phoneNumber != undefined) {
            ehr.phoneNumber = phoneNumber;
        }
        if (gender != undefined) {
            ehr.gender = gender;
        }
        if (nationality != undefined) {
            ehr.nationality = nationality;
        }
        if (bloodType != undefined) {
            ehr.bloodType = bloodType;
        }
        if (height != undefined) {
            ehr.height = height;
        }
        if (weight != undefined) {
            ehr.weight = weight;
        }
        if (pulseRate != undefined) {
            ehr.pulseRate = pulseRate;
        }
        if (bloodPressure != undefined) {
            ehr.bloodPressure = bloodPressure;
        }
        if (respiratoryRate != undefined) {
            ehr.respiratoryRate = respiratoryRate;
        }
        if (medicalHistory != undefined) {
            ehr.medicalHistory = medicalHistory;
        }
        if (diagnose != undefined) {
            ehr.diagnose = diagnose;
        }
        if (insuranceName != undefined) {
            ehr.insuranceName = insuranceName;
        }

        await ctx.stub.putState(ehrId, Buffer.from(JSON.stringify(ehr)));
        console.log("ERH smart contract " , ehr)
        console.info('============= END : Update Ehr ===========');

    } else {
        throw Error(`Only Hospital Admin permitted to Update EHR`)
    }
    }

    async queryAllEhrs(ctx) {
        const startKey = '';
        const endKey = '';
        const allResults = [];

        console.log("ctx.clientIdentity ", ctx.clientIdentity)
        const mspId = ctx.clientIdentity.getMSPID()
        if (mspId == "HospitalMSP") {
        
            for await (const {key, value} of ctx.stub.getStateByRange(startKey, endKey)) {
                const strValue = Buffer.from(value).toString('utf8');
                let record;
                try {
                    record = JSON.parse(strValue);
                } catch (err) {
                    console.log(err);
                    record = strValue;
                }
                allResults.push({ Key: key, Record: record });
            }
            console.info(allResults);
            return JSON.stringify(allResults);
        } else {
            throw Error(`Only Hospital Admin permitted to Get All EHR`)
        }
    }

    async queryBelongingEhrs(ctx) {
        const allResults = [];

        console.log("ctx.clientIdentity ", ctx.clientIdentity)
        const mspId = ctx.clientIdentity.getMSPID()
        if (mspId == "InsuranceMSP") {
            let query;
            if (ctx.clientIdentity.attrs['hf.Affiliation'] == undefined) {
                query = {
                    "selector": {
                       "_id": {
                          "$gt": null
                       }
                    }
                 }
            } else {
                query = {
                    "selector": {
                        "insuranceName": ctx.clientIdentity.attrs['hf.Affiliation'].split('.')[1]
                    }
                }
                console.log("inside msp insurance ", ctx.clientIdentity.attrs['hf.Affiliation'].split('.')[1])
                console.log("QUERY RESULT ", await ctx.stub.getQueryResult(JSON.stringify(query)) )
            }
            for await (const {key, value} of ctx.stub.getQueryResult(JSON.stringify(query))) {
                const strValue = Buffer.from(value).toString('utf8');
                let record;
                try {
                    record = JSON.parse(strValue);
                } catch (err) {
                    console.log(err);
                    record = strValue;
                }
                allResults.push({ Key: key, Record: record });
            }
            console.info(allResults);
            return JSON.stringify(allResults);
        } else {
            throw Error(`Only Insurance Organization permitted to Get Belonging EHR`)
        }
    }

    async queryEhrHistory(ctx, ehrId) {

        const mspId = ctx.clientIdentity.getMSPID()
        const historyIterator = await ctx.stub.getHistoryForKey(ehrId)

        let result = []
        historyIterator.hasNext = async function hasNext() {
            const item = await this.next();
            this.current = item.value;
            return !item.done;
        };
        while (await historyIterator.hasNext()) {
            const transaction = historyIterator.current;

            const value = Buffer(JSON.parse(JSON.stringify(Buffer.from(transaction.value)))).toString()
            result.push(
                {
                    txId: transaction.txId,
                    value: JSON.parse(Buffer.from(transaction.value).toString('utf8')),
                    timestamp: new Date((transaction.timestamp.seconds.low + ((transaction.timestamp.nanos / 1000000) / 1000)) * 1000)
                }
            )
        }
        result = JSON.stringify(result);
        
        if (mspId == "HospitalMSP" || mspId == "InsuranceMSP") {
            return result;
        } else {
            throw new Error(`Unknown MSPID: ${mspId}`);
        }
    }

}

module.exports = Ehr;
