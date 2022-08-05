/* eslint-disable */
const Xdc3 = require("xdc3");
require("dotenv").config();
const h = require("chainlink-test-helpers");
const express = require('express')
const bodyParser = require('body-parser');
const app = express()
const port = process.env.EA_PORT || 5001

app.use(bodyParser.json())

app.post('/api/registerFlights', async (req, res) => {

  console.log("request value is", req.body, req.body[1], req.body[2], req.body[3])

  const xdc3 = new Xdc3(
    new Xdc3.providers.HttpProvider(process.env.CONNECTION_URL)
  );

  const _flightAddress = req.body[1];
  const _careerFlightNo = req.body[2];
  const _serviceProviderName = req.body[3];
  const deployed_private_key = process.env.PRIVATE_KEY;

  console.log("_flightAddress Address is, ", _flightAddress);
  console.log("_careerFlightNo is, ", _careerFlightNo);
  console.log("_serviceProviderName is, ", _serviceProviderName);

  const requestorABI = require("./ABI/requestAbi.json");
  const requestorcontractAddr = process.env.REQUESTOR_CONTRACT;

  // // //Defining requestContract
  const requestContract = new xdc3.eth.Contract(requestorABI, requestorcontractAddr);
  console.log("Requestor Contract is, ", requestContract);
  const account = xdc3.eth.accounts.privateKeyToAccount(deployed_private_key);
  console.log("Account Address is, ", account, account.address);
  const nonce = await xdc3.eth.getTransactionCount(account.address);
  const gasPrice = await xdc3.eth.getGasPrice();

  const tx = {
    nonce: nonce,
    data: requestContract.methods.registerFlights(_flightAddress, _careerFlightNo, _serviceProviderName).encodeABI(),
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
    .once("receipt", console.log);
  var request = h.decodeRunRequest(txt.logs[3]);
  const resultset = { requestId: request.id, requestData: request.data.toString("utf-8") };
  console.log("resultSet  ,", resultset)
  res.send(resultset)
})


app.post('/api/bookInsurance', async (req, res) => {

  console.log("request value is", req.body, req.body[1], req.body[2], req.body[3], req.body[4], req.body[5])

  const xdc3 = new Xdc3(
    new Xdc3.providers.HttpProvider(process.env.CONNECTION_URL)
  );

  const _passengerAddress = req.body[1];
  const _carrierFlightNumber = req.body[2];
  const _departureOn = req.body[3];
  const _arrivalOn = req.body[4];
  const _travelday = req.body[5];
  const deployed_private_key = process.env.PRIVATE_KEY;

  console.log("_passengerAddress Address is, ", _passengerAddress);
  console.log("_carrierFlightNumber is, ", _carrierFlightNumber);
  console.log("_departureOn is, ", _departureOn);
  console.log("_arrivalOn is, ", _arrivalOn);
  console.log("_travelday is, ", _travelday);

  const requestorABI = require("./ABI/requestAbi.json");
  const requestorcontractAddr = process.env.REQUESTOR_CONTRACT;

  // // //Defining requestContract
  const requestContract = new xdc3.eth.Contract(requestorABI, requestorcontractAddr);
  console.log("Requestor Contract is, ", requestContract);
  const account = xdc3.eth.accounts.privateKeyToAccount(deployed_private_key);
  console.log("Account Address is, ", account, account.address);
  const nonce = await xdc3.eth.getTransactionCount(account.address);
  const gasPrice = await xdc3.eth.getGasPrice();

  const tx = {
    nonce: nonce,
    data: requestContract.methods.registerFlights(_passengerAddress, _carrierFlightNumber, _departureOn, _arrivalOn, _travelday).encodeABI(),
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
    .once("receipt", console.log);
  var request = h.decodeRunRequest(txt.logs[3]);
  const resultset = { requestId: request.id, requestData: request.data.toString("utf-8") };
  console.log("resultSet  ,", resultset)
  res.send(resultset)
})


app.post('/api/submitClaim', async (req, res) => {

  console.log("request value is", req.body, req.body[1], req.body[3])

  const xdc3 = new Xdc3(
    new Xdc3.providers.HttpProvider(process.env.CONNECTION_URL)
  );

  const _policyId = req.body[1];
  const _jobid = req.body[2];
  const _oracleAddress = req.body[3];
  const deployed_private_key = process.env.PRIVATE_KEY;

  console.log("_policyId  is, ", _policyId);
  console.log("_jobid is, ", _jobid);
  console.log("_oracleAddress is, ", _oracleAddress);

  const requestorABI = require("./ABI/requestAbi.json");
  const requestorcontractAddr = process.env.REQUESTOR_CONTRACT;

  // // //Defining requestContract
  const requestContract = new xdc3.eth.Contract(requestorABI, requestorcontractAddr);
  console.log("Requestor Contract is, ", requestContract);
  const account = xdc3.eth.accounts.privateKeyToAccount(deployed_private_key);
  console.log("Account Address is, ", account, account.address);
  const nonce = await xdc3.eth.getTransactionCount(account.address);
  const gasPrice = await xdc3.eth.getGasPrice();

  const tx = {
    nonce: nonce,
    data: requestContract.methods.submitMyClaim(_policyId, _jobid, _oracleAddress).encodeABI(),
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
    .once("receipt", console.log);
  var request = h.decodeRunRequest(txt.logs[3]);
  const resultset = { requestId: request.id, requestData: request.data.toString("utf-8") };
  console.log("resultSet  ,", resultset)
  res.send(resultset)
})

app.listen(port, () => console.log(`Listening on port ${port}!`))
