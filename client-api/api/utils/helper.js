const getAdminIdentity = (organizationType) => {
    if (organizationType == "hospital") {
        return "adminHospital";
    } else if (organizationType == "insurance") {
        return "adminInsurance";
    } else {
        throw "Organization type must either from hospital or insurance"
    }
    
}

const getOrganizationTypeFromMSP = (mspId) => {
    if (mspId == "HospitalMSP") {
        return "hospital";
    } else if (mspId == "InsuranceMSP") {
        return "insurance";
    } else {
        throw "Invalid MSPID"
    }
    
}

module.exports = {getAdminIdentity, getOrganizationTypeFromMSP};