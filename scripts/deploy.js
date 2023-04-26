const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying LendToken contract with account:", deployer.address);
  console.log("Deploying BorrowToken contract with account:", deployer.address);
  console.log("Deploying Oracle contract with account:", deployer.address);

  const LendToken = await ethers.getContractFactory("LendToken");
  const BorrowToken = await ethers.getContractFactory("BorrowToken");
  const Oracle = await ethers.getContractFactory("Oracle");

  const lendToken = await LendToken.deploy();
  const borrowToken = await BorrowToken.deploy();
  const oracle = await Oracle.deploy();

  await lendToken.deployed();
  await borrowToken.deployed();
  await oracle.deployed();

  console.log("LendToken contract deployed to:", lendToken.address);
  console.log("BorrowToken contract deployed to:", borrowToken.address);
  console.log("Oracle contract deployed to:", oracle.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
