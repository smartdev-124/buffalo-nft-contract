const { expect } = require("chai");
const hre = require("hardhat");
const ethers = require("ethers")

/**
 * Test 1 - Purchase one buffalo *
 * Test 2 - Purchase 12 buffalos *
 * Test 3 - Purchase 15 buffalos *
 * Test 4 - Hit max cap expect error *
 * Test 5 - Hit max cap, update max cap, expect success *
 * Test 6 - Capture historical events
 */
it("Purchase one buffalo", async function () {
  const Buffalos = await hre.ethers.getContractFactory("Buffalos");
  const buffalo = await Buffalos.deploy("Buffalos", "MAD", "TEST", 100);
  await buffalo.deployed();

  await buffalo.mintBuffalo( 1, { value: ethers.utils.parseEther("0.35") })
  const nftURI = await buffalo.tokenURI(1)
  expect(nftURI).to.equal("TEST1")

});

// need to get addresses
it("Purchase 12 Buffalos", async function () {
  const [owner, signer] = await hre.ethers.getSigners();

  const Buffalos = await hre.ethers.getContractFactory("Buffalos");
  const buffalo = await Buffalos.deploy("Buffalos", "MAD", "TEST", 100);
  await buffalo.deployed();

  await buffalo.connect(signer).mintBuffalo( 12, { value: ethers.utils.parseEther("4") })
  const signerBalance = await buffalo.balanceOf(signer.address)
  expect(signerBalance).to.equal(12)
});

it("Purchase 15 Buffalos", async function () {
  const [owner, signer] = await hre.ethers.getSigners();

  const Buffalos = await hre.ethers.getContractFactory("Buffalos");
  const buffalo = await Buffalos.deploy("Buffalos", "MAD", "TEST", 100);
  await buffalo.deployed();

  await buffalo.connect(signer).mintBuffalo( 15, { value: ethers.utils.parseEther("5") })
  const signerBalance = await buffalo.balanceOf(signer.address)
  expect(signerBalance).to.equal(15)
});

it("Hit max cap expect errors", async function () {
  const [owner, signer] = await hre.ethers.getSigners();

  const Buffalos = await hre.ethers.getContractFactory("Buffalos");
  const buffalo = await Buffalos.deploy("Buffalos", "MAD", "TEST", 12);
  await buffalo.deployed();

  await expect(buffalo.connect(signer).mintBuffalo( 15, { value: ethers.utils.parseEther("5") })).to.be.revertedWith('Sale has already ended.')
});

it("Hit max cap, update max cap, expect success", async function () {
  const [owner, signer] = await hre.ethers.getSigners();

  const Buffalos = await hre.ethers.getContractFactory("Buffalos");
  const buffalo = await Buffalos.deploy("Buffalos", "MAD", "TEST", 12);
  await buffalo.deployed();

  await expect(buffalo.connect(signer).mintBuffalo( 15, { value: ethers.utils.parseEther("5") })).to.be.revertedWith('Sale has already ended.')

  await buffalo.connect(owner).changeMaxSupply(100)
  const maxSupply = await buffalo.MAX_SUPPLY()
  expect(maxSupply).to.equal(100)

  await buffalo.connect(owner).mintBuffalo( 15, { value: ethers.utils.parseEther("5") })

  const ownerSupply = await buffalo.balanceOf(owner.address)
  expect(ownerSupply).to.equal(45)
});
