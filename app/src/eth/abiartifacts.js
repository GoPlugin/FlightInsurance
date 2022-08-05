import { ethers } from 'ethers';

import {
  FlightDelayInsurance as flightInsuranceAddress
} from '../deploy.json';

import { abi as flightInsuranceAbi } from '../artifacts/contracts/FlightDelayInsurance.sol/FlightDelayInsurance.json';

export function createInstance(provider, name) {
  if (name === "FlightInsurance") {
    return new ethers.Contract(flightInsuranceAddress, flightInsuranceAbi, provider);
  }
}
