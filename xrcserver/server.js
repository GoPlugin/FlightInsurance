/* eslint-disable */
const Xdc3 = require("xdc3");
require("dotenv").config();
const h = require("chainlink-test-helpers");
const express = require('express')
const bodyParser = require('body-parser');
const app = express()
const port = process.env.EA_PORT || 5001


const xdc3 = new Xdc3(
  new Xdc3.providers.HttpProvider(process.env.CONNECTION_URL)
);

const requestorABI = require("./ABI/FDI.json");
const requestorcontractAddr = process.env.REQUESTOR_CONTRACT;
const deployed_private_key = process.env.PRIVATE_KEY;

app.use(bodyParser.json())

app.post('/api/passengerRegister', async (req, res) => {

  console.log("request value is", req);
  const passengerAddress = req.body.passengerAddress;
  const passengerPnr = req.body.passengerPnr;
  const airlineKey = req.body.airlineKey;


  console.log("passengerAddress, ", passengerAddress);
  console.log("passengerPnr, ", passengerPnr);
  console.log("airlineKey, ", airlineKey);

  
  // // //Defining requestContract
  const requestContract = new xdc3.eth.Contract(requestorABI, requestorcontractAddr);
  // console.log("requestContract",requestContract)
  
  const account = xdc3.eth.accounts.privateKeyToAccount(deployed_private_key);
  // console.log("Account Address is, ", account, account.address);
  const nonce = await xdc3.eth.getTransactionCount(account.address);
  const gasPrice = await xdc3.eth.getGasPrice();
  // console.log("ACCOUNT",account)
  // console.log("nonce",nonce)
  console.log("gasPrice before",gasPrice)

  const tx = {
    nonce: nonce,
    data: requestContract.methods.passengerRegister(passengerAddress, passengerPnr, airlineKey).encodeABI(),
    gasPrice: gasPrice,
    to: process.env.REQUESTOR_CONTRACT,
    from: account.address,
  };

  const gasLimit = await xdc3.eth.estimateGas(tx);
  tx["gasLimit"] = gasLimit;
  console.log("gasPrice", gasPrice);
  const signed = await xdc3.eth.accounts.signTransaction(
    tx,
    deployed_private_key
  )

  console.log("gasPrice", gasPrice);
  const txt = await xdc3.eth
    .sendSignedTransaction(signed.rawTransaction)
    .once("receipt", console.log)
    .then(function(receipt){
      console.log("receipt value is",receipt.logs[0].topics[0]);
    });

  // const transaction = xdc3.eth.abi.decodeLog(
                        
  //                     )
  const events = await requestContract.getPastEvents("PassengerEvents",{fromBlock:"latest",toBlock:"latest"});
    //console.log("events",events);
    // console.log("events",events);
    console.log("events",events[0].returnValues.passengerKey);
    res.json({patientKey:events[0].returnValues.passengerKey,message:events[0].returnValues.eventType})
  // console.log("log-0", txt.logs[0]);
  // var request = txt.logs[0];
  // console.log("request", request);
  // const resultset = { requestId: request.id, requestData: request.data.toString("utf-8") };
  // console.log("resultSet  ,", resultset);
  // res.send(resultset);
  // console.log("gaslimit", gasLimit);
})

app.post('/api/airlineRegister', async (req, res) => {

  console.log("request value is", req);
  const airlineAddress = req.body.airlineAddress;
  const iataSymbol = req.body.iataSymbol;
  const airlineName = req.body.airlineName;


  console.log("airlineAddress, ", airlineAddress);
  console.log("iataSymbol, ", iataSymbol);
  console.log("airlineName, ", airlineName);

  
  // // //Defining requestContract
  const requestContract = new xdc3.eth.Contract(requestorABI, requestorcontractAddr);
  // console.log("requestContract",requestContract)
  
  const account = xdc3.eth.accounts.privateKeyToAccount(deployed_private_key);
  // console.log("Account Address is, ", account, account.address);
  const nonce = await xdc3.eth.getTransactionCount(account.address);
  const gasPrice = await xdc3.eth.getGasPrice();
  // console.log("ACCOUNT",account)
  // console.log("nonce",nonce)
  console.log("gasPrice before",gasPrice)

  const tx = {
    nonce: nonce,
    data: requestContract.methods.airlineRegister(airlineAddress, iataSymbol, airlineName).encodeABI(),
    gasPrice: gasPrice,
    to: process.env.REQUESTOR_CONTRACT,
    from: account.address,
  };

  const gasLimit = await xdc3.eth.estimateGas(tx);
  tx["gasLimit"] = gasLimit;
  console.log("gasPrice", gasPrice);
  const signed = await xdc3.eth.accounts.signTransaction(
    tx,
    deployed_private_key
  )

  console.log("gasPrice", gasPrice);
  const txt = await xdc3.eth
    .sendSignedTransaction(signed.rawTransaction)
    .once("receipt", console.log)
    .then(function(receipt){
      console.log("receipt value is",receipt.logs[0].topics[0]);
    });

  // const transaction = xdc3.eth.abi.decodeLog(
                        
  //                     )
  const events = await requestContract.getPastEvents("airlineEvents",{fromBlock:"latest",toBlock:"latest"});
    //console.log("events",events);
    // console.log("events",events);
    console.log("events",events[0].returnValues.airlineKey);
    res.json({patientKey:events[0].returnValues.airlineKey,message:events[0].returnValues.evenType})
  // console.log("log-0", txt.logs[0]);
  // var request = txt.logs[0];
  // console.log("request", request);
  // const resultset = { requestId: request.id, requestData: request.data.toString("utf-8") };
  // console.log("resultSet  ,", resultset);
  // res.send(resultset);
  // console.log("gaslimit", gasLimit);
})

app.post('/api/setAirlineStake', async (req, res) => {

  //console.log("request value is", req.body, req.body[1], req.body[3])
  const stakeFund = req.body.stakeFund;
  const airlineAddress = req.body.airlineAddress;
  const airlineKey = req.body.airlineKey;


  console.log("stakeFund, ", stakeFund);
  console.log("airlineAddress, ", airlineAddress);
  console.log("airlineKey, ", airlineKey);



  // // //Defining requestContract
  const requestContract = new xdc3.eth.Contract(requestorABI, requestorcontractAddr);
  console.log("Requestor Contract is, ", requestContract);
  const account = xdc3.eth.accounts.privateKeyToAccount(deployed_private_key);
  console.log("Account Address is, ", account, account.address);
  const nonce = await xdc3.eth.getTransactionCount(account.address);
  const gasPrice = await xdc3.eth.getGasPrice();

  const tx = {
    nonce: nonce,
    data: requestContract.methods.setAirlineStake(stakeFund, airlineAddress, airlineKey).encodeABI(),
    gasPrice: gasPrice,
    to: process.env.REQUESTOR_CONTRACT,
    from: account.address,
  };

  const gasLimit = await xdc3.eth.estimateGas(tx);
  tx["gasLimit"] = gasLimit;

  const signed = await xdc3.eth.accounts.signTransaction(
    tx,
    deployed_private_key
  );

  const txt = await xdc3.eth
    .sendSignedTransaction(signed.rawTransaction)
    .once("receipt", console.log)
    .then(function(receipt){
      console.log("receipt value is",receipt.logs[0].topics[0]);
    });
    const events = await requestContract.getPastEvents("airlineEvents",{fromBlock:"latest",toBlock:"latest"});
    //console.log("events",events);
    console.log("events",events[0].returnValues.airlineKey);
    res.json({patientKey:events[0].returnValues.airlineKey,message:events[0].returnValues.evenType});

})

app.post('/api/bookInsurance', async (req, res) => {

  const flightIcao = req.body.flightIcao;
  const passengerKey = req.body.passengerKey;
  const airlineKey = req.body.airlineKey;
  const departureTimeStamp = req.body.departureTimeStamp;
  const arrivalTimeStamp = req.body.arrivalTimeStamp;
  

  console.log("flightIcao, ", flightIcao);
  console.log("passengerKey, ", passengerKey);
  console.log("airlineKey, ", airlineKey);
  console.log("departureTimeStamp, ", departureTimeStamp);
  console.log("arrivalTimeStamp, ", arrivalTimeStamp);



  // // //Defining requestContract
  const requestContract = new xdc3.eth.Contract(requestorABI, requestorcontractAddr);
  console.log("Requestor Contract is, ", requestContract);
  const account = xdc3.eth.accounts.privateKeyToAccount(deployed_private_key);
  console.log("Account Address is, ", account, account.address);
  const nonce = await xdc3.eth.getTransactionCount(account.address);
  const gasPrice = await xdc3.eth.getGasPrice();

  const tx = {
    nonce: nonce,
    data: requestContract.methods.bookInsurance(flightIcao, passengerKey, airlineKey, departureTimeStamp, arrivalTimeStamp).encodeABI(),
    gasPrice: gasPrice,
    to: process.env.REQUESTOR_CONTRACT,
    from: account.address,
  };

  const gasLimit = await xdc3.eth.estimateGas(tx);
  tx["gasLimit"] = gasLimit;

  const signed = await xdc3.eth.accounts.signTransaction(
    tx,
    deployed_private_key
  );

  const txt = await xdc3.eth
    .sendSignedTransaction(signed.rawTransaction)
    .once("receipt", console.log)
    .then(function(receipt){
      console.log("receipt value is",receipt.logs[0].topics[0]);
    });
    const events = await requestContract.getPastEvents("InsuranceEvents",{fromBlock:"latest",toBlock:"latest"});
    //console.log("events",events);
    console.log("events",events[0].returnValues.policyKey);
    res.json({patientKey:events[0].returnValues.policyKey,message:events[0].returnValues.eventType});
  // var request = h.decodeRunRequest(txt.logs[3]);
  // const resultset = { requestId: request.id, requestData: request.data.toString("utf-8") };
  // console.log("resultSet  ,", resultset)
  // res.send(resultset)
})

app.post('/api/flightInsuranceDetailsCheck', async (req, res) => {

  const policyKey = req.body.policyKey;
  const passengerKey = req.body.passengerKey;



  console.log("policyKey, ", policyKey);
  console.log("passengerKey, ", passengerKey);


     // // //Defining requestContract
     const requestContract = new xdc3.eth.Contract(requestorABI, requestorcontractAddr);
     console.log("Requestor Contract is, ", requestContract);
     const result = await requestContract.methods.listAccessStatus(policyKey,passengerKey);
})

app.listen(port, () => console.log(`Listening on port ${port}!`))
