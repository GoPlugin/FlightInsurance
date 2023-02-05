/* eslint-disable */
const Xdc3 = require("xdc3");
//const web3 = new Xdc3()
require("dotenv").config();
const h = require("chainlink-test-helpers");
const express = require('express')
const bodyParser = require('body-parser');
//const app = express()
const port = process.env.EA_PORT || 5001
const gasLimit = 200000


const xdc3 = new Xdc3(
  new Xdc3.providers.HttpProvider(process.env.CONNECTION_URL)
);
const expectedBlockTime = 3000;
const sleep = (milliseconds) => {
  return new Promise(resolve => setTimeout(resolve, milliseconds))
}
const requestorABI = require("./FlightDelayCompensation.json");
const requestorcontractAddr = process.env.REQUESTOR_CONTRACT;
const deployed_private_key = process.env.PRIVATE_KEY;

const  getTxnStatus = async (txHash,web3) => {
  let transactionReceipt = null
  while (transactionReceipt == null) { // Waiting expectedBlockTime until the transaction is mined
    transactionReceipt = await xdc3.eth.getTransactionReceipt(txHash);
    await sleep(expectedBlockTime)
  }
  console.log("Got the transaction receipt: ", transactionReceipt, transactionReceipt.status)
  if (transactionReceipt.status) {
    return [txHash, true];
  } else {
    return [txHash, false];
  }
}
//app.use(bodyParser.json())

module.exports.delayCompensation = async (data) => {

  //console.log("request value is", req);
  const passengerAddress = data.passengerAddress;
  const passengerPnr = data.passengerPnr;
  const airlineTag = data.airlineTag;
  const depDate = data.depDate;
  const arrDate = data.arrDate;  
  const kycHash = data.kycHash; 
  const flightNumber = data.flightNumber;
  const passengerRegNumber = data.passengerRegNumber;
  const compAmt = data.compAmt;
  const cs = data.cs;
  const fs = data.fs;


  console.log("passengerAddress, ", passengerAddress);
  console.log("passengerPnr, ", passengerPnr);
  console.log("airlineTag, ", airlineTag);
  console.log("depDate, ", depDate);
  console.log("arrDate, ", arrDate);
  console.log("kycHash, ", kycHash);
  console.log("flightNumber, ", flightNumber);
  console.log("passengerRegNumber, ", passengerRegNumber);
  console.log("compAmt, ", compAmt);
  console.log("cs, ", cs);
  console.log("fs, ", fs);

  
  
  // // //Defining requestContract
  //console.log("ABI", requestorABI);
  const requestContract = new xdc3.eth.Contract(requestorABI, requestorcontractAddr);
  // console.log("requestContract",requestContract)
  
  const account = xdc3.eth.accounts.privateKeyToAccount(deployed_private_key);
  // console.log("Account Address is, ", account, account.address);
  const nonce = await xdc3.eth.getTransactionCount(account.address);
  const gasPrice = await xdc3.eth.getGasPrice();
  console.log("gasPrice before",gasPrice)

  const tx = {
    nonce: nonce,
    data: requestContract.methods.delayCompensation(passengerAddress, passengerPnr, airlineTag, depDate, arrDate, kycHash, flightNumber, passengerRegNumber, compAmt, cs, fs).encodeABI(),
    gasPrice: gasPrice,
    to: process.env.REQUESTOR_CONTRACT,
    from: account.address,
  };

  //const gasLimit = await xdc3.eth.estimateGas(tx);
  tx["gasLimit"] = gasLimit;
  console.log("gasPrice", gasPrice);
  const signed = await xdc3.eth.accounts.signTransaction(
    tx,
    deployed_private_key
  )

  console.log("gasPrice", gasPrice);
  const returnData = await new Promise((resolve, reject) => {
    const txt = xdc3.eth
    .sendSignedTransaction(signed.rawTransaction)
    .on("transactionHash", async function (transactionHash){
    const [txhash, status] = await getTxnStatus(transactionHash, xdc3)
    console.log("`tx`h",txhash)
    resolve({txhash,status})
  })
  });
  return returnData;
}

module.exports.delayCompensationUpdate = async (data) => {

  //console.log("request value is", req);
  const passengerPnr = data.passengerPnr;
  const airlineTag = data.airlineTag;
  const depDate = data.depDate;
  const arrDate = data.arrDate;  
  const passengerRegNumber = data.passengerRegNumber;
  const cs = data.cs;


  console.log("passengerPnr, ", passengerPnr);
  console.log("airlineTag, ", airlineTag);
  console.log("depDate, ", depDate);
  console.log("arrDate, ", arrDate);
  console.log("passengerRegNumber, ", passengerRegNumber);
  console.log("cs, ", cs);

  
  
  // // //Defining requestContract
  //console.log("ABI", requestorABI);
  const requestContract = new xdc3.eth.Contract(requestorABI, requestorcontractAddr);
  // console.log("requestContract",requestContract)
  
  const account = xdc3.eth.accounts.privateKeyToAccount(deployed_private_key);
  // console.log("Account Address is, ", account, account.address);
  const nonce = await xdc3.eth.getTransactionCount(account.address);
  const gasPrice = await xdc3.eth.getGasPrice();
  console.log("gasPrice before",gasPrice)

  const tx = {
    nonce: nonce,
    data: requestContract.methods.delayCompensationUpdate(passengerPnr, airlineTag, depDate, arrDate, passengerRegNumber, cs).encodeABI(),
    gasPrice: gasPrice,
    to: process.env.REQUESTOR_CONTRACT,
    from: account.address,
  };

  //const gasLimit = await xdc3.eth.estimateGas(tx);
  tx["gasLimit"] = gasLimit;
  console.log("gasPrice", gasPrice);
  const signed = await xdc3.eth.accounts.signTransaction(
    tx,
    deployed_private_key
  )

  console.log("gasPrice", gasPrice);
  const returnData = await new Promise((resolve, reject) => {
    const txt = xdc3.eth
    .sendSignedTransaction(signed.rawTransaction)
    .on("transactionHash", async function (transactionHash){
    const [txhash, status] = await getTxnStatus(transactionHash, xdc3)
    console.log("`tx`h",txhash)
    resolve({txhash,status})
  })
  });
  return returnData;
}

module.exports.delayCompensationFlightUpdate = async (data) => {

  //console.log("request value is", req);
  const passengerPnr = data.passengerPnr;
  const airlineTag = data.airlineTag;
  const depDate = data.depDate;
  const arrDate = data.arrDate;  
  const passengerRegNumber = data.passengerRegNumber;
  const fs = data.fs;


  console.log("passengerPnr, ", passengerPnr);
  console.log("airlineTag, ", airlineTag);
  console.log("depDate, ", depDate);
  console.log("arrDate, ", arrDate);
  console.log("passengerRegNumber, ", passengerRegNumber);
  console.log("fs, ", fs);

  
  
  // // //Defining requestContract
  //console.log("ABI", requestorABI);
  const requestContract = new xdc3.eth.Contract(requestorABI, requestorcontractAddr);
  // console.log("requestContract",requestContract)
  
  const account = xdc3.eth.accounts.privateKeyToAccount(deployed_private_key);
  // console.log("Account Address is, ", account, account.address);
  const nonce = await xdc3.eth.getTransactionCount(account.address);
  const gasPrice = await xdc3.eth.getGasPrice();
  console.log("gasPrice before",gasPrice)

  const tx = {
    nonce: nonce,
    data: requestContract.methods.delayCompensationFlightUpdate(passengerPnr, airlineTag, depDate, arrDate, passengerRegNumber, fs).encodeABI(),
    gasPrice: gasPrice,
    to: process.env.REQUESTOR_CONTRACT,
    from: account.address,
  };

  //const gasLimit = await xdc3.eth.estimateGas(tx);
  tx["gasLimit"] = gasLimit;
  console.log("gasPrice", gasPrice);
  const signed = await xdc3.eth.accounts.signTransaction(
    tx,
    deployed_private_key
  )

  console.log("gasPrice", gasPrice);
  const returnData = await new Promise((resolve, reject) => {
    const txt = xdc3.eth
    .sendSignedTransaction(signed.rawTransaction)
    .on("transactionHash", async function (transactionHash){
    const [txhash, status] = await getTxnStatus(transactionHash, xdc3)
    console.log("`tx`h",txhash)
    resolve({txhash,status})
  })
  });
  return returnData;
}
