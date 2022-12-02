const express = require('express')
const bodyParser = require('body-parser')
const { enrollAdmin } = require('./service/enrollAdmin')
const { getAllEhr } = require('./service/getAllEhr')
const { createEhr } = require('./service/createEhr')
const { registerUser } = require('./service/registerUser')

var jsonParser = bodyParser.json()
// create application/x-www-form-urlencoded parser
var urlencodedParser = bodyParser.urlencoded({ extended: false })
const cors = require('cors')
const { getEhrById } = require('./service/getEhrById')
const { getInsuranceEhr } = require('./service/getInsuranceEHR')
const { loginUser } = require('./service/loginUser')
const { getEhrHistory } = require('./service/getEhrHistory')
const { updateEhr } = require('./service/updateEhr')
const app = express()
const port = 8000

app.use(cors());

app.get('/', (req, res) => {
  res.send('Hello World!')
})

app.get('/ehr/', urlencodedParser, async function(req, res) {
    if (req.headers.authorization == undefined) {
        return res.status(401).send({"result": "Unauthorized"})
    }
    
    try {
        var result = await getAllEhr(req.headers.authorization);
        if (result == null) {
            result = "Failed to get all EHR"
        }
        
        res.send({
            "result": result
        })
    } catch (error) {
        res.status(400).send(
            {
                "result": error
            }
        )
    }
})

app.get('/insurance/ehr/', urlencodedParser, async function(req, res) {
    console.log("insurance ehr")
    if (req.headers.authorization == undefined) {
        return res.status(401).send({"result": "Unauthorized"})
    }
    try {
        var result = await getInsuranceEhr(req.headers.authorization);
        if (result == null) {
            return res.status(200).send({"result": "No EHR found"})
        }
        
        res.send({
            "result": result
        })
    } catch (error) {
        res.status(400).send(
            {
                "result": error
            }
        )
    }
    
})

app.get('/ehr/:id', urlencodedParser, async function(req, res) {
    if (req.headers.authorization == undefined) {
        return res.status(401).send({"result": "Unauthorized"})
    }
    try {
        var result = await getEhrById(req.params.id, req.headers.authorization);
        if (result == null) {
            result = `EHR with id: ${req.params.id} not found`
        }
        res.send({
            "result": result
        })
    } catch (error) {
        res.status(400).send(
            {
                "result": error
            }
        )
    }
    
})

app.get('/ehr/history/:id', urlencodedParser, async function(req, res) {
    if (req.headers.authorization == undefined) {
        return res.status(401).send({"result": "Unauthorized"})
    }
    try {
        var result = await getEhrHistory(req.params.id, req.headers.authorization);
        if (result == null) {
            result = `EHR with id: ${req.params.id} not found`
        }
        res.send({
            "result": result
        })
    } catch (error) {
        res.status(400).send(
            {
                "result": error
            }
        )
    }
    
})

app.post('/ehr/', jsonParser, async function(req, res) {
    if (req.headers.authorization == undefined) {
        return res.status(401).send({"result": "Unauthorized"})
    }
    try {
        console.log("REQ", req.body)

        const name = req.body.name;
        const dateOfBirth = req.body.dateOfBirth;
        const address = req.body.address;
        const phoneNumber = req.body.phoneNumber;
        const gender = req.body.gender;
        const nationality = req.body.nationality;
        const bloodType = req.body.bloodType;
        const height = req.body.height;
        const weight = req.body.weight;
        const pulseRate = req.body.pulseRate;
        const bloodPressure = req.body.bloodPressure;
        const respiratoryRate = req.body.respiratoryRate;
        const medicalHistory = req.body.medicalHistory;
        const diagnose = req.body.diagnose;
        const insuranceName = req.body.insuranceName;
        
        const result = await createEhr(
            req.headers.authorization,
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
            )
        res.send({
            "message": "Transaction has been submitted",
            "ehrId": result
        })
    } catch (error) {
        res.status(400).send(
            {
                "result": error
            }
        )
    }
})

app.put('/ehr/:id', jsonParser, async function(req, res) {
    if (req.headers.authorization == undefined) {
        return res.status(401).send({"result": "Unauthorized"})
    }
    try {
        console.log("REQ", req.body)

        const name = req.body.name;
        const dateOfBirth = req.body.dateOfBirth;
        const address = req.body.address;
        const phoneNumber = req.body.phoneNumber;
        const gender = req.body.gender;
        const nationality = req.body.nationality;
        const bloodType = req.body.bloodType;
        const height = req.body.height;
        const weight = req.body.weight;
        const pulseRate = req.body.pulseRate;
        const bloodPressure = req.body.bloodPressure;
        const respiratoryRate = req.body.respiratoryRate;
        const medicalHistory = req.body.medicalHistory;
        const diagnose = req.body.diagnose;
        const insuranceName = req.body.insuranceName;
        
        const result = await updateEhr(
            req.headers.authorization,
            req.params.id,
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
            )
        res.send({
            "result": result
        })
    } catch (error) {
        res.status(400).send(
            {
                "result": error
            }
        )
    }
})

app.post('/enroll/admin/', jsonParser, async function(req, res) {
    try{
        console.log("REQ", req.body)
        const enrollId = req.body.enrollId;
        const enrollSecret = req.body.enrollSecret;
        const organizationType = req.body.organizationType;
        console.log("ENROLLID ", enrollId)
        console.log("enrollSecret ", enrollSecret)
        if (enrollId != null && enrollSecret != null) {
            enrollAdmin(enrollId, enrollSecret, organizationType)
        }
        res.send({
            'result': `Successful enrolled admin with id: ${enrollId}`
        })
    } catch (error) {
        res.status(400).send(
            {
                "result": error
            }
        )
    }
    
})

app.post('/register/', jsonParser, async function(req, res) {
    try{
        console.log("REQ", req.body)
        const email = req.body.email;
        const organization = req.body.organization;
        const organizationType = req.body.organizationType;
        console.log("email ", email)
        console.log("organization ", organization)
        console.log("organizationType ", organizationType)
        
        if (email != null) {
            const secret = await registerUser(email, organization, organizationType)
            res.send({
                'result': `Successful enrolled user with id: ${email}`
            })
            // res.send({
            //     "secret": secret
            // })
        }
    } catch (error) {
        res.status(400).send(
            {
                "result": error
            }
        )
    }

})

app.post('/login/', jsonParser, async function(req, res) {
    try{
        console.log("REQ", req.body)
        const email = req.body.email;
        const password = req.body.password;
        console.log("EMAIL ", email)
        console.log("password ", password)
        if (email != null) {
            const result = await loginUser(email)
            res.send(result)
            
        }
    } catch (error) {
        res.status(400).send(
            {
                "result": error
            }
        )
    }

})

app.get('*', function(req, res) {
    res.send("blank")
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})

Object.defineProperty(String.prototype, 'capitalize', {
    value: function() {
      return this.charAt(0).toUpperCase() + this.slice(1);
    },
    enumerable: false
  });
  