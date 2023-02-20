const { ethers, upgrades } = require('hardhat');
const { writeFileSync } = require('fs');

async function deploy(name, ...params) {
  const Contract = await ethers.getContractFactory(name);
  return await Contract.deploy(...params).then(f => f.deployed());
}

async function main() {

  const staking = await ethers.getContractFactory("FDCStaking");
  const stakingproxy = await upgrades.deployProxy(staking, ["0xb3db178db835b4dfcb4149b2161644058393267d"]);
  await stakingproxy.deployed();

  const rewards = await ethers.getContractFactory("FDCReward");
  const rewarsproxy = await upgrades.deployProxy(rewards, ["0xb3db178db835b4dfcb4149b2161644058393267d"]);
  await rewarsproxy.deployed();

  writeFileSync('deploy.json', JSON.stringify({
    FDCStaking: stakingproxy.address,
    FDCReward: rewarsproxy.address
  }, null, 2));

}

if (require.main === module) {
  main().then(() => process.exit(0))
    .catch(error => { console.error(error); process.exit(1); });
}