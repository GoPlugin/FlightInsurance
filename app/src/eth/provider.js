/* eslint-disable no-unused-vars */
import { ethers } from 'ethers';

const rpcendpoint = "https://rpc.apothem.network"

export function createProvider() {
  return new ethers.providers.JsonRpcProvider(rpcendpoint, 4);
}