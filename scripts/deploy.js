const hre = require("hardhat");
require('dotenv').config();
const { baseURI, artist, token } = process.env;

async function main() {
  const Buffalos = await hre.ethers.getContractFactory("Buffalos");
  const buffalo = await Buffalos.deploy("Buffalos", "Buff", baseURI, 100, 1637290616, artist, token, 0);

  await buffalo.deployed();

  console.log("Contract deployed to address:", buffalo.address)

}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
