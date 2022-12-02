const EHRParser = (obj) => {
    console.log("OBJH ", obj)
    console.log("obj[0]['Record'] ", obj[0]['Record'])
    obj[0]['Record']["medicalHistory"]= JSON.parse(obj[0]['Record']["medicalHistory"]);
    return obj;
}

const getAllEhrParser = (stringEhr) => {
    let result = JSON.parse(stringEhr)
    console.log("result ", result[0])
    result.map((item, index) => {
        result[index]['Record']["medicalHistory"] = JSON.parse(item['Record']['medicalHistory'])
        result[index]['Record']["diagnose"] = JSON.parse(item['Record']['diagnose'])
        // result[index]['Record']["paymentHistory"] = JSON.parse(item['Record']['paymentHistory'])
    })
    return result;
}

const getEhrParser = (stringEhr) => {
    let result = JSON.parse(stringEhr)
    result["medicalHistory"] = JSON.parse(result['medicalHistory'])
    result["diagnose"] = JSON.parse(result['diagnose'])
    return result;
}


const getHistoryEhrParser = (stringEhr) => {
    let result = JSON.parse(stringEhr)
    console.log("result ", result[0])
    result.map((item, index) => {
        result[index]['value']["medicalHistory"] = JSON.parse(item['value']['medicalHistory'])
        result[index]['value']["diagnose"] = JSON.parse(item['value']['diagnose'])
        // result[index]['value']["paymentHistory"] = JSON.parse(item['value']['paymentHistory'])
    })
    return result;
}

module.exports = {EHRParser, getAllEhrParser, getEhrParser, getHistoryEhrParser};